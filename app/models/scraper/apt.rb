require 'kimurai'
require "graphql/client"
require "graphql/client/http"
require 'selenium-webdriver'

class Saver < Kimurai::Pipeline
  def process_item(property, options: {})
    # Here you can save item to the database, send it to a remote API or
    # simply save item to a file format using `save_to` helper:

    # To get the name of current spider: `spider.class.name`
    # save_to "db/#{spider.class.name}.json", item, format: :json
    # puts "[SAVER] Processing #{property}"

    # Save property to SPARK backend if floor_plans are available
    if property[:floorPlans].size > 0
      # property[:cityId] = city_id(property[:city], property[:state])
      property_from_spark = find_or_create_property(property)
      property[:id] = property_from_spark["id"].to_i
     
      # Reset existing property units' availability to unavailable
      reset_units_availability(property[:id])

      # find and/or create floor plans for the property
      new_floor_plans = []
      new_units = []

      updated_floor_plans = []
      updated_units = []

      property[:floorPlans].each do |fp|
        fp[:propertyId] = property[:id]
        floor_plan_from_spark = find_floor_plan(fp, property_from_spark["floorPlans"])

        if floor_plan_from_spark
          fp[:id] = floor_plan_from_spark["id"].to_i

          # find or create units for this floor plan
          fp[:units].each do |u|
            u[:propertyId] = property[:id]
            u[:floorPlanId] = fp[:id]
            # if u[:id].blank?
            unit_from_spark = find_unit(u, property_from_spark["typeDetails"])
            # end
            if unit_from_spark
              u[:id] = unit_from_spark["id"].to_i
              updated_units << u
            else
              new_units << u #.except(:)
            end
          end
          updated_floor_plans << fp.except(:units)
        else
          new_floor_plans << fp.except(:units)
        end
      end

      if updated_floor_plans.size > 0
        # Update floor plans
        update_floor_plans(updated_floor_plans)
      end

      if updated_units.size > 0
        # Update unit pricing / availability information
        update_units(updated_units)
      end

      # Save the new floor plans
      if new_floor_plans.size > 0
        floor_plans_from_spark = create_floor_plans(new_floor_plans)
        # TODO: Create units for newly created floor plans
        property[:floorPlans].each do |fp|
          if fp[:id].blank?
            floor_plan_from_spark = find_floor_plan(fp, floor_plans_from_spark)
            if floor_plan_from_spark
              fp[:id] = floor_plan_from_spark["id"].to_i
              fp[:units].each do |u|
                u[:propertyId] = property[:id].to_i
                u[:floorPlanId] = fp[:id].to_i
                new_units << u #.except(:)
              end
            end
          end
        end
        # # floor_plans_from_spark.each do |fp|
        # end
      end

      # Save the new units
      if new_units.size > 0
        units_from_spark = create_units(new_units)
        property[:floorPlans].each do |fp|
          fp[:units].each do |u|
            if u[:id].blank?
              unit_from_spark = find_unit(u, units_from_spark)
              # byebug if !unit_from_spark
              u[:id] = unit_from_spark["id"].to_i
            end
          end
        end
      end

      puts "[INFO] Saved - #{property[:name].upcase}"
      # save_to "saved.json", property, format: :pretty_json
    else
      puts "[INFO] Skipped - #{property[:name].upcase}"
      # save_to "skipped.json", property, format: :pretty_json
    end

    property
  end


  # def city_id(city_name, state_name=nil)
  #   @cities.each do |city|
  #     if city_name.downcase == city["name"].downcase
  #       return city["id"].to_i
  #     end
  #   end
  #   return state_name ? create_city(city_name, state_name)["id"].to_i : nil
  # end

  def find_floor_plan(floor_plan, floor_plans)
    # find floor_plan from the spark property
    if floor_plans
      floor_plans.each do |fp|
        if fp["name"].downcase == floor_plan[:name].downcase && fp["sqft"] == floor_plan[:sqft]
          return fp
        end
      end
    end
    return nil 
  end

  def find_unit(unit, units)
    # check if it exists in spark property
    if units
      units.each do |u|
        if u["aptNo"].to_s.downcase == unit[:aptNo].downcase
          return u
        end
      end
    end
    return nil 
  end

  def find_or_create_property(property)
    result = Scraper::Spark::Client.query(FindProperty, variables: {cityId: property[:cityId], search: property[:name]})

    if result.original_hash["data"]["propertiesWithoutJoinData"] && 
      result.original_hash["data"]["propertiesWithoutJoinData"]["edges"].size > 0
      puts "[INFO] Property found - #{property[:name].upcase}"
      return result.original_hash["data"]["propertiesWithoutJoinData"]["edges"][0]["node"]
    else
      # create property and return
      return create_property(property)
    end
  end

  def self.sign_in
    mutation = <<-'GRAPHQL'
      mutation ($email: String!, $password: String!) {
        signin(input: { email: $email, password: $password }) {
          user {
            name
            isAdmin
            isVa
            approved
            status
            subscriptions {
              isTrial
              currentEndDatetime
              currentStartDatetime
              active
              status
            }
          }
          authenticationToken
          message
          errors
        }
      }
    GRAPHQL
    Kernel.const_set(:SignIn, Scraper::Spark::Client.parse(mutation))

    result = Scraper::Spark::Client.query(SignIn, variables: {email: "ashwin@complitech.net", password: "12345678"})

    # puts result.data
    puts result.original_hash["data"]
  end

  def create_city(city_name, state_name, is_visible=false)
    result = Scraper::Spark::Client.query(CreateCity, variables: {name: city_name, stateName: state_name, isVisible: is_visible})

    if result.original_hash["data"]["cityCreate"]["errors"] &&
      result.original_hash["data"]["cityCreate"]["errors"].size > 0 
      puts "[ERROR] City was not created - #{city_name}"
    else
      puts "[INFO] City created successfully - #{city_name}"
      @cities = all_cities
      return result.original_hash["data"]["cityCreate"]["city"]
    end
    return nil
  end

  def create_floor_plans(floor_plans)
    result = Scraper::Spark::Client.query(FloorPlanMultiCreate, variables: {createFloorPlans: floor_plans})

    if result.original_hash["data"]["floorPlanMultiCreate"]["errors"] &&
      result.original_hash["data"]["floorPlanMultiCreate"]["errors"].size > 0 
      puts "[ERROR] Floor plans were not created"
    else
      puts "[INFO] Floor plans created successfully - #{result.original_hash["data"]["floorPlanMultiCreate"]["floorPlans"].size} floor plans"
      return result.original_hash["data"]["floorPlanMultiCreate"]["floorPlans"]
    end
    return nil
  end

  def update_floor_plans(floor_plans)
    result = Scraper::Spark::Client.query(FloorPlanMultiUpdate, variables: {updateFloorPlans: floor_plans})

    if result.original_hash["data"]["floorPlanMultiUpdate"]["errors"] && 
      result.original_hash["data"]["floorPlanMultiUpdate"]["errors"].size > 0 
      puts "[ERROR] Floor plans were not updated"
    else
      puts "[INFO] Floor plans updated successfully - #{result.original_hash["data"]["floorPlanMultiUpdate"]["floorPlans"].size} floor plans"
      return result.original_hash["data"]["floorPlanMultiUpdate"]["floorPlans"]
    end
    return nil
  end

  def create_units(units)
    result = Scraper::Spark::Client.query(UnitMultiCreate, variables: {createUnits: units})

    if result.original_hash["data"]["unitMultiCreate"] &&
      result.original_hash["data"]["unitMultiCreate"]["errors"] &&
      result.original_hash["data"]["unitMultiCreate"]["errors"].size > 0 
      puts "[ERROR] Units were not created"
    else
      puts "[INFO] Units created successfully - #{result.original_hash["data"]["unitMultiCreate"]["units"].size} units"
      return result.original_hash["data"]["unitMultiCreate"]["units"]
    end
    return nil
  end

  def reset_units_availability(property_id)
    result = Scraper::Spark::Client.query(PropertyUnitsReset, variables: {propertyId: property_id.to_i})
    if result.original_hash["data"]["unitMultiUpdateAvailability"]["errors"] &&
      result.original_hash["data"]["unitMultiUpdateAvailability"]["errors"].size > 0 
      puts "[ERROR] Units availability was not reset"
      return false
    else
      puts "[INFO] Units availability updated successfully"
      return true
    end
    return nil
  end

  def update_units(units)
    result = Scraper::Spark::Client.query(UnitMultiUpdate, variables: {updateUnits: units})
    if result.original_hash["data"]["unitMultiUpdate"]["errors"] &&
      result.original_hash["data"]["unitMultiUpdate"]["errors"].size > 0 
      puts "[ERROR] Units were not updated"
    else
      puts "[INFO] Units updated successfully - #{result.original_hash["data"]["unitMultiUpdate"]["units"].size} units"
      return result.original_hash["data"]["unitMultiUpdate"]["units"]
    end
    return nil
  end

  def create_property(property)
    result = Scraper::Spark::Client.query(CreateProperty, variables: {name: property[:name], neighborhood: property[:neighborhood], zip: property[:zip], cityId: property[:cityId], address: property[:address]})

    if result.original_hash["data"]["propertyCreate"]["errors"] &&
      result.original_hash["data"]["propertyCreate"]["errors"].size > 0 
      puts "[ERROR] Property was not created - #{property[:name].upcase}"
    else
      puts "[INFO] Property created successfully - #{property[:name].upcase}"
      return result.original_hash["data"]["propertyCreate"]["property"]
    end
    # byebug
    return nil
  end
end

class Scraper::Apt < Kimurai::Base
  include Scraper::Utils

  USER_AGENTS = [
    "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1",
    "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.34 (KHTML, like Gecko) Version/11.0 Mobile/15A5341f Safari/604.1",
    "Mozilla/5.0 (Linux; Android 7.1.1; Google Pixel Build/NMF26F; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/54.0.2840.85 Mobile Safari/537.36",
    # "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)",
    # "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)"
  ]

  @name = "Apt"
  # @engine = :mechanize
  @engine = :selenium_chrome

  @runner = nil

	@scrape_property = false

  @pipelines = [:saver]
	
	PROXIES = [
		"p.webshare.io:10000:socks5",
		"p.webshare.io:10001:socks5",
		"p.webshare.io:10002:socks5",
		"p.webshare.io:10003:socks5",
		"p.webshare.io:10004:socks5",
		"p.webshare.io:10005:socks5",
		"p.webshare.io:10006:socks5",
		"p.webshare.io:10007:socks5",
		"p.webshare.io:10008:socks5",
		"p.webshare.io:10009:socks5",
		"p.webshare.io:10010:socks5",
		"p.webshare.io:10011:socks5",
		"p.webshare.io:10012:socks5",
		"p.webshare.io:10013:socks5",
		"p.webshare.io:10014:socks5",
		"p.webshare.io:10015:socks5",
		"p.webshare.io:10016:socks5",
		"p.webshare.io:10017:socks5",
		"p.webshare.io:10018:socks5",
		"p.webshare.io:10019:socks5",
		"p.webshare.io:10020:socks5",
		"p.webshare.io:10021:socks5",
		"p.webshare.io:10022:socks5",
		"p.webshare.io:10023:socks5",
		"p.webshare.io:10024:socks5",
		"p.webshare.io:10025:socks5",
		"p.webshare.io:10026:socks5",
		"p.webshare.io:10027:socks5",
		"p.webshare.io:10028:socks5",
		"p.webshare.io:10029:socks5",
		"p.webshare.io:10030:socks5",
		"p.webshare.io:10031:socks5",
		"p.webshare.io:10032:socks5",
		"p.webshare.io:10033:socks5",
		"p.webshare.io:10034:socks5",
		"p.webshare.io:10035:socks5",
		"p.webshare.io:10036:socks5",
		"p.webshare.io:10037:socks5",
		"p.webshare.io:10038:socks5",
		"p.webshare.io:10039:socks5",
		"p.webshare.io:10040:socks5",
		"p.webshare.io:10041:socks5",
		"p.webshare.io:10042:socks5",
		"p.webshare.io:10043:socks5",
		"p.webshare.io:10044:socks5",
		"p.webshare.io:10045:socks5",
		"p.webshare.io:10046:socks5",
		"p.webshare.io:10047:socks5",
		"p.webshare.io:10048:socks5",
		"p.webshare.io:10049:socks5"
	]

  @config = {
    # user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
    user_agent: -> { USER_AGENTS.sample },
    # skip_request_errors: [{ error: RuntimeError, message: "404 => Net::HTTPNotFound"},
    skip_request_errors: [{ error: RuntimeError, skip_on_failure: true }],
		proxy: -> { PROXIES.sample },
		retry_request_errors: [Net::ReadTimeout],
    session: {
      before_request: {
        change_user_agent: true,
    
        # Clear all cookies before each request, works for all drivers
        clear_cookies: true,

        # If you want to clear all cookies + set custom cookies (`cookies:` option above should be presented)
        # use this option instead (works for all drivers)
        clear_and_set_cookies: true,
      }
    },
		# proxy: -> { PROXIES.sample }
  }
  
  # @cities = []

  @url_hash = []
  # CITY_NAME = "Chicago"
  @start_urls = []
  # @start_urls = [
  #               "https://www.apartments.com/the-clark-chicago-il/1vftkw4/",
  #               # "https://www.apartments.com/cascade-chicago-il/hc2k503/",
  #               # "https://www.apartments.com/3eleven-chicago-il/66x7f8r/",
  #    ]

	@scrape_history = nil

	def self.close_spider
    if failed?
			Scraper::Apt.scrape_history.cancel
    end
		Scraper::Apt.scrape_history.scrape_entry_histories.where(status: "inprogress").update_all(status: "canceled")
  end

  def self.runner
    @runner
  end

  def config
    @config
  end

  def self.runner=(runner=nil)
    @runner = runner
  end

	# def self.scrape_property                                     #For Single Property Scrape
	# 	@scrape_property
	# end

	def self.scraper_name=(name = "Apt")                  
		@name = name
	end

	# def self.scrape_property=(scrape_property = false)           #For Single Property Scrape
	# 	@scrape_property = scrape_property
	# end

  def self.url_hash
    @url_hash
  end

  def self.url_hash=(url_hash=[])
    @url_hash = url_hash
  end

	def self.scrape_history
		@scrape_history
	end

	def self.scrape_history=(scrape_history = nil)
		@scrape_history = scrape_history
	end

  def self.start_urls=(urls=[])
    @start_urls = urls
  end

  def city_name(entry)
    entry ? Scraper::Apt.runner.entry(entry[:entry_id]).link.city.name : nil
  end

	def city_id(entry)
    entry ? Scraper::Apt.runner.entry(entry[:entry_id]).link.city.s_id : nil
	end

  def scrape_property_city_name(scraper)                 #For Single Property Scrape
    scraper.runner.link.city.name
  end

  def scrape_property_city_id(scraper)                   #For Single Property Scrape
    scraper.runner.link.city.s_id
  end

  def start_entry(entry)
    entry ? ScrapeEntry.find(entry[:entry_id]) : nil
  end

  def finish_entry(entry, property)
    se = ScrapeEntry.find(entry[:entry_id])
		seh = Scraper::Apt.scrape_history.scrape_entry_histories.find_by(scrape_entry: se)
    l = se.link
    l ? l.update(name: property[:name], s_id: property[:id]) : nil
    # se ? se.update(status: "completed", raw_hash: property.to_json) : nil

		seh.update(status: "completed", raw_hash: property.to_json)

		SprapeSchema.subscriptions.trigger(:scrape_progress, {}, {scrape_history: seh.scrape_history})

  end

	def is_fetch_floorplan_images(entry)           # For Single Property Scrape                                                    
		unless entry
			self.scrape_property &&  self.runner.link.fetch_floorplan_images ? true : false
		else 
			entry[:fetch_floorplan_images]
		end
	end

  def parse(response, url:, data: {})

		# scrape_property = Scraper::Apt.scrape_property       # For Single Property Scrape
		# entry = nil

		# unless scrape_property
		# 	entry = Scraper::Apt.url_hash.find {|u| u[:url] == url}
		# 	start_entry(entry)
		# end

		urls = Scraper::Apt.url_hash.pluck(:url)

		in_parallel(:parse_property, urls, threads: 3, delay: rand(2..5), config: self.config, data: {scraper: Scraper::Apt, property_scrape: false})

  end

	def parse_property(response, url:, data: {})

		entry = data[:scraper].url_hash.find {|u| u[:url] == url}
		start_entry(entry) unless data[:property_scrape]

    property = {}
		fp_error = false

    # Property Name
    property[:name] = response.css("h1","propertyName").text.strip 

		if property[:name] == "Access Denied" || property[:name] == "Can we help you get somewhere else?"
			p "=========================================  Exiting Due To #{property[:name]}  ============================================="
			return 0
		end
    property[:neighborhood] = response.xpath("//a[@class='neighborhood']").text.strip

    # Initialize floor_plans
    property[:floorPlans] = []

    # Address
    property[:address] = response.xpath("//div[@class='propertyAddressContainer']/h2/span[1]").text.strip + ", " + 
          response.xpath("//div[@class='propertyAddressContainer']/h2/span[2]").text.strip + ", " +
          response.xpath("//div[@class='propertyAddressContainer']/h2/span[3]/span[1]").text.strip + " " +
          response.xpath("//div[@class='propertyAddressContainer']/h2/span[3]/span[2]").text.strip

    # City name
		unless data[:property_scrape]
			property[:city] = city_name(entry) 
			property[:cityId] = city_id(entry)
		else 
			property[:city] = scrape_property_city_name(data[:scraper])         #For Single Property Scrape
			property[:cityId] = scrape_property_city_id(data[:scraper])
		end

    # State name
    property[:state] = response.xpath("//div[@class='propertyAddressContainer']/h2/span[3]/span[1]").text.strip

    # zip code
    property[:zip] = response.xpath("//div[@class='propertyAddressContainer']/h2/span[3]/span[2]").text.strip

		# debugger

		unavailable_fp_btn = response.xpath("//div[@data-tab-content-id='all']//div[@class='unAvailableFloorPlanBtnSection mortar-wrapper']//button[@class='js-showUnavailableFloorPlansButton']")

		if unavailable_fp_btn.any?
			browser.find(:xpath, "//div[@data-tab-content-id='all']//div[@class='unAvailableFloorPlanBtnSection mortar-wrapper']//button[@class='js-showUnavailableFloorPlansButton']").click
			sleep 5
		end

    # Parse floor_plans from response
    # response.xpath("//div[@data-tab-content-id='all']//div[@class='priceGridModelWrapper js-unitContainer mortar-wrapper']").each do |fp|

		browser.current_response.xpath("//div[@data-tab-content-id='all']//div[@class='priceGridModelWrapper js-unitContainer mortar-wrapper']").each do |fp|

      floor_plan = {}
      # Floor Plan Name
      # floor_plan[:name] = t.css(".modelName").text.strip
      floor_plan[:name] = fp.xpath(".//span[@class='modelName']").text
      # Floor Plan Min Rent
      floor_plan[:rentMin] = fp.css(".rentLabel").text.strip.split(" – ")[0].to_s.gsub("$","").gsub(",","").to_i
      # Floor Plan Max Rent
      floor_plan[:rentMax] = fp.css(".rentLabel").text.strip.split(" – ")[1].to_s.gsub("$","").gsub(",","").to_i
      # Floor Plan Type / Bed
      floor_plan[:bed] = parse_bed(fp.xpath(".//span[@class='detailsTextWrapper']/span").to_a[0].text)
      # Floor Plan Baths
      floor_plan[:bath] = parse_bath(fp.xpath(".//span[@class='detailsTextWrapper']/span").to_a[1].text)
      # Floor Plan Size / Sq Feet
      floor_plan[:sqft] = parse_size(fp.xpath(".//span[@class='detailsTextWrapper']/span").to_a[2].text).to_s
      floor_plan[:sqftMin] = parse_size(fp.xpath(".//span[@class='detailsTextWrapper']/span[3]").text)
      floor_plan[:sqftMax] = parse_size(fp.xpath(".//span[@class='detailsTextWrapper']/span[3]").text)
      floor_plan[:isAvailable] = fp.xpath(".//span[@class='detailsTextWrapper']//span[@class='availabilityInfo']").text
      # Floor Plan Deposit Amount
      floor_plan[:deposit] = parse_amount(fp.xpath(".//span[@class='detailsTextWrapper leaseDepositLabel']/span[2]").text)
			floor_plan[:plan2dLink] = nil
      # Floor Plan Availability
      # t.xpath(".//span[@class='detailsTextWrapper leaseDepositLabel']/span[3]").text  
      # Floor Plan Image
      # t.xpath(".//div[@class='floorPlanButtonImage']").to_s
			# if is_fetch_floorplan_images(entry)
			if entry[:fetch_floorplan_images]
				begin
					var = fp.xpath(".//div[@class='column2']//div").to_a[0]["data-modelname"]
					var2 = fp.xpath(".//div[@class='column2']//div").to_a[0]["data-rentalkey"]
					browser.find(:xpath, "//div[@data-tab-content-id='all']//button[@data-modelname='#{var}'][@data-rentalkey='#{var2}'][@class='actionLinks js-priceGridModelfloorPlanButtons']").click
					sleep 2
					fp_img_url = browser.current_response.xpath("//ul[@id='photoList']//li[1]//div[@class='backgroundImageWrapper imgReady']").to_a[0]&.attributes["data-img-src"]&.value
					floor_plan[:plan2dLink] = fp_img_url
					browser.find(:xpath, "//div[@id='js-headerUtilities'][@class='headerUtilities']//button[@class='close'][@aria-label='close']").click
					sleep 3
				rescue => e
					fp_error = var.nil? ? false : true
					begin 
						if browser.current_response.xpath("//div[@id='js-headerUtilities'][@class='headerUtilities']//button[@class='close'][@aria-label='close']")
							browser.find(:xpath, "//div[@id='js-headerUtilities'][@class='headerUtilities']//button[@class='close'][@aria-label='close']").click
						end
						rescue => error
							puts error
						end
					puts e
				end
			end

      if floor_plan[:bed]
        floor_plan[:units] = []
        # Parse UNITS in the floor plan
        fp.parent.xpath(".//li[@data-model='#{fp.xpath(".//span[@class='modelName']").text.gsub("'","")}']").each do |u|
          unit = {}
          # Unit number / Appartment Number
          unit[:aptNo] = parse_aptno(u.xpath(".//div[@class='unitColumn column']//button").text.strip)
          # Unit rent / price
          unit[:price] = parse_amount(u.xpath(".//div[@class='pricingColumn column']//span[2]").text.strip)
          # Unit Size / Sq Feet
          unit[:size] = parse_size(u.xpath(".//div[@class='sqftColumn column']//span[2]").text.strip)
          # Unit available date 
          unit[:moveIn] = parse_date(u.xpath(".//div[@class='availableColumn column']//span[@class='dateAvailable']").children[2].text.strip)

          unit[:isAvailable] = !unit[:moveIn].blank?

          floor_plan[:units] << unit
        end
        property[:floorPlans] << floor_plan
      end

			puts floor_plan
    end

		Link.find_by(url: entry[:url]).update(fetch_floorplan_images: false) unless fp_error	
		puts property

    # puts "HASH BEFORE: #{property}"
    send_item property
    # puts "HASH TO BE SAVED: #{property.to_json}"
    finish_entry(entry, property) unless data[:property_scrape]

	end

  def all_cities
    result = Scraper::Spark::Client.query(AllCities)

    puts "[INFO] All cities fetched successfully."
    return result.original_hash["data"]["allCities"]
  end

  # def initialize

  #   # @cities = all_cities
    
  #   super

  #   puts ">>>>>  Scraper Initialize Completed"
  # end

end

# Sprape.crawl!
# Sprape.sign_in
# s = Sprape.new
# Sprape.crawl!

