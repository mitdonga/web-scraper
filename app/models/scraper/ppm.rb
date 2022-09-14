require 'kimurai'
require "graphql/client"
require "graphql/client/http"
require 'selenium-webdriver'
# require "httparty"
# require 'execjs'

# class Saver < Kimurai::Pipeline
#   def process_item(property, options: {})
#     # Here you can save item to the database, send it to a remote API or
#     # simply save item to a file format using `save_to` helper:

#     # To get the name of current spider: `spider.class.name`
#     # save_to "db/#{spider.class.name}.json", item, format: :json
#     # puts "[SAVER] Processing #{property}"

#     # Save property to SPARK backend if floor_plans are available
#     if property[:floorPlans].size > 0
#       # property[:cityId] = city_id(property[:city], property[:state])
#       property_from_spark = find_or_create_property(property)
#       property[:id] = property_from_spark["id"].to_i
     
#       # Reset existing property units' availability to unavailable
#       reset_units_availability(property[:id])

#       # find and/or create floor plans for the property
#       new_floor_plans = []
#       new_units = []

#       updated_floor_plans = []
#       updated_units = []

#       property[:floorPlans].each do |fp|
#         fp[:propertyId] = property[:id]
#         floor_plan_from_spark = find_floor_plan(fp, property_from_spark["floorPlans"])

#         if floor_plan_from_spark
#           fp[:id] = floor_plan_from_spark["id"].to_i 

#           # find or create units for this floor plan
#           fp[:units].each do |u|
#             u[:propertyId] = property[:id]
#             u[:floorPlanId] = fp[:id]
#             # if u[:id].blank?
#             unit_from_spark = find_unit(u, property_from_spark["typeDetails"])
#             # end
#             if unit_from_spark
#               u[:id] = unit_from_spark["id"].to_i
#               updated_units << u
#             else
#               new_units << u #.except(:)
#             end
#           end
#           updated_floor_plans << fp.except(:units)
#         else
#           new_floor_plans << fp.except(:units)
#         end
#       end

#       if updated_floor_plans.size > 0
#         # Update floor plans
#         update_floor_plans(updated_floor_plans)
#       end

#       if updated_units.size > 0
#         # Update unit pricing / availability information
#         update_units(updated_units)
#       end

#       # Save the new floor plans
#       if new_floor_plans.size > 0
#         floor_plans_from_spark = create_floor_plans(new_floor_plans)
#         # TODO: Create units for newly created floor plans
#         property[:floorPlans].each do |fp|
#           if fp[:id].blank?
#             floor_plan_from_spark = find_floor_plan(fp, floor_plans_from_spark)
#             if floor_plan_from_spark
#               fp[:id] = floor_plan_from_spark["id"].to_i
#               fp[:units].each do |u|
#                 u[:propertyId] = property[:id].to_i
#                 u[:floorPlanId] = fp[:id].to_i
#                 new_units << u #.except(:)
#               end
#             end
#           end
#         end
#         # # floor_plans_from_spark.each do |fp|
#         # end
#       end

#       # Save the new units
#       if new_units.size > 0
#         units_from_spark = create_units(new_units)
#         property[:floorPlans].each do |fp|
#           fp[:units].each do |u|
#             if u[:id].blank?
#               unit_from_spark = find_unit(u, units_from_spark)
#               # byebug if !unit_from_spark
#               u[:id] = unit_from_spark["id"].to_i
#             end
#           end
#         end
#       end

#       puts "[INFO] Saved - #{property[:name].upcase}"
#       # save_to "saved.json", property, format: :pretty_json
#     else
#       puts "[INFO] Skipped - #{property[:name].upcase}"
#       # save_to "skipped.json", property, format: :pretty_json
#     end

#     property
#   end


#   # def city_id(city_name, state_name=nil)
#   #   @cities.each do |city|
#   #     if city_name.downcase == city["name"].downcase
#   #       return city["id"].to_i
#   #     end
#   #   end
#   #   return state_name ? create_city(city_name, state_name)["id"].to_i : nil
#   # end

#   def find_floor_plan(floor_plan, floor_plans)
#     # find floor_plan from the spark property
#     if floor_plans
#       floor_plans.each do |fp|
#         if fp["name"].downcase == floor_plan[:name].downcase
#           return fp
#         end
#       end
#     end
#     return nil 
#   end

#   def find_unit(unit, units)
#     # check if it exists in spark property
#     if units
#       units.each do |u|
#         if u["aptNo"].to_s.downcase == unit[:aptNo].downcase
#           return u
#         end
#       end
#     end
#     return nil 
#   end

#   def find_or_create_property(property)
#     result = Scraper::Spark::Client.query(FindProperty, variables: {cityId: property[:cityId], search: property[:name]})

#     if result.original_hash["data"]["propertiesWithoutJoinData"] && 
#       result.original_hash["data"]["propertiesWithoutJoinData"]["edges"].size > 0
#       puts "[INFO] Property found - #{property[:name].upcase}"
#       return result.original_hash["data"]["propertiesWithoutJoinData"]["edges"][0]["node"]
#     else
#       # create property and return
#       return create_property(property)
#     end
#   end

#   def self.sign_in
#     mutation = <<-'GRAPHQL'
#       mutation ($email: String!, $password: String!) {
#         signin(input: { email: $email, password: $password }) {
#           user {
#             name
#             isAdmin
#             isVa
#             approved
#             status
#             subscriptions {
#               isTrial
#               currentEndDatetime
#               currentStartDatetime
#               active
#               status
#             }
#           }
#           authenticationToken
#           message
#           errors
#         }
#       }
#     GRAPHQL
#     Kernel.const_set(:SignIn, Scraper::Spark::Client.parse(mutation))

#     result = Scraper::Spark::Client.query(SignIn, variables: {email: "ashwin@complitech.net", password: "12345678"})

#     # puts result.data
#     puts result.original_hash["data"]
#   end

#   def create_city(city_name, state_name, is_visible=false)
#     result = Scraper::Spark::Client.query(CreateCity, variables: {name: city_name, stateName: state_name, isVisible: is_visible})

#     if result.original_hash["data"]["cityCreate"]["errors"] &&
#       result.original_hash["data"]["cityCreate"]["errors"].size > 0 
#       puts "[ERROR] City was not created - #{city_name}"
#     else
#       puts "[INFO] City created successfully - #{city_name}"
#       @cities = all_cities
#       return result.original_hash["data"]["cityCreate"]["city"]
#     end
#     return nil
#   end

#   def create_floor_plans(floor_plans)
#     result = Scraper::Spark::Client.query(FloorPlanMultiCreate, variables: {createFloorPlans: floor_plans})

#     if result.original_hash["data"]["floorPlanMultiCreate"]["errors"] &&
#       result.original_hash["data"]["floorPlanMultiCreate"]["errors"].size > 0 
#       puts "[ERROR] Floor plans were not created"
#     else
#       puts "[INFO] Floor plans created successfully - #{result.original_hash["data"]["floorPlanMultiCreate"]["floorPlans"].size} floor plans"
#       return result.original_hash["data"]["floorPlanMultiCreate"]["floorPlans"]
#     end
#     return nil
#   end

#   def update_floor_plans(floor_plans)
#     result = Scraper::Spark::Client.query(FloorPlanMultiUpdate, variables: {updateFloorPlans: floor_plans})

#     if result.original_hash["data"]["floorPlanMultiUpdate"]["errors"] && 
#       result.original_hash["data"]["floorPlanMultiUpdate"]["errors"].size > 0 
#       puts "[ERROR] Floor plans were not updated"
#     else
#       puts "[INFO] Floor plans updated successfully - #{result.original_hash["data"]["floorPlanMultiUpdate"]["floorPlans"].size} floor plans"
#       return result.original_hash["data"]["floorPlanMultiUpdate"]["floorPlans"]
#     end
#     return nil
#   end

#   def create_units(units)
#     result = Scraper::Spark::Client.query(UnitMultiCreate, variables: {createUnits: units})

#     if result.original_hash["data"]["unitMultiCreate"] &&
#       result.original_hash["data"]["unitMultiCreate"]["errors"] &&
#       result.original_hash["data"]["unitMultiCreate"]["errors"].size > 0 
#       puts "[ERROR] Units were not created"
#     else
#       puts "[INFO] Units created successfully - #{result.original_hash["data"]["unitMultiCreate"]["units"].size} units"
#       return result.original_hash["data"]["unitMultiCreate"]["units"]
#     end
#     return nil
#   end

#   def reset_units_availability(property_id)
#     result = Scraper::Spark::Client.query(PropertyUnitsReset, variables: {propertyId: property_id.to_i})
#     if result.original_hash["data"]["unitMultiUpdateAvailability"]["errors"] &&
#       result.original_hash["data"]["unitMultiUpdateAvailability"]["errors"].size > 0 
#       puts "[ERROR] Units availability was not reset"
#       return false
#     else
#       puts "[INFO] Units availability updated successfully"
#       return true
#     end
#     return nil
#   end

#   def update_units(units)
#     result = Scraper::Spark::Client.query(UnitMultiUpdate, variables: {updateUnits: units})
#     if result.original_hash["data"]["unitMultiUpdate"]["errors"] &&
#       result.original_hash["data"]["unitMultiUpdate"]["errors"].size > 0 
#       puts "[ERROR] Units were not updated"
#     else
#       puts "[INFO] Units updated successfully - #{result.original_hash["data"]["unitMultiUpdate"]["units"].size} units"
#       return result.original_hash["data"]["unitMultiUpdate"]["units"]
#     end
#     return nil
#   end

#   def create_property(property)
#     result = Scraper::Spark::Client.query(CreateProperty, variables: {name: property[:name], neighborhood: property[:neighborhood], zip: property[:zip], cityId: property[:cityId], address: property[:address]})

#     if result.original_hash["data"]["propertyCreate"]["errors"] &&
#       result.original_hash["data"]["propertyCreate"]["errors"].size > 0 
#       puts "[ERROR] Property was not created - #{property[:name].upcase}"
#     else
#       puts "[INFO] Property created successfully - #{property[:name].upcase}"
#       return result.original_hash["data"]["propertyCreate"]["property"]
#     end
#     # byebug
#     return nil
#   end
# end

class Scraper::Ppm < Kimurai::Base
  include Scraper::Utils

  @name = "Ppm"
  @engine = :mechanize
  # @engine = :poltergeist_phantomjs

  @runner = nil

#   @pipelines = [:saver]

  @config = {
    user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
    before_request: { delay: 3..6 },
    skip_request_errors: [{ error: RuntimeError, message: "404 => Net::HTTPNotFound" }]
  }
  
  # @cities = []

  @url_hash = []
  # CITY_NAME = "Chicago"
  @start_urls = ["https://ppmapartments.com/properties/river-north/750-n-rush/"]
  # @start_urls = [
  #               "https://www.apartments.com/the-clark-chicago-il/1vftkw4/",
  #               "https://www.apartments.com/cascade-chicago-il/hc2k503/",
  #               # "https://www.apartments.com/3eleven-chicago-il/66x7f8r/",
  #    ]

#   def self.runner
#     @runner
#   end

#   def self.runner=(runner=nil)
#     @runner = runner
#   end

#   def self.url_hash
#     @url_hash
#   end

#   def self.url_hash=(url_hash=[])
#     @url_hash = url_hash
#   end

#   def self.start_urls=(urls=[])
#     @start_urls = urls
#   end

#   def city_name(entry)
#     entry ? Scraper::Ppm.runner.entry(entry[:entry_id]).link.city.name : nil #<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< where is .entry?
#   end

#   def city_id(entry)
#     entry ? Scraper::Ppm.runner.entry(entry[:entry_id]).link.city.s_id : nil
#   end

#   def start_entry(entry)
#     entry ? ScrapeEntry.find(entry[:entry_id]).inprogress! : nil
#   end

#   def finish_entry(entry, property)
#     se = ScrapeEntry.find(entry[:entry_id])
#     l = se.link
#     l ? l.update(name: property[:name], s_id: property[:id]) : nil
#     se ? se.update(status: "completed", raw_hash: property.to_json) : nil
#   end

  def parse(response, url:, data: {})
   #  entry = Scraper::Apt.url_hash.find {|u| u[:url] == url}   
   #  start_entry(entry)
    property = {}

    # Property Name
    property[:name] = response.css("h1","entry-title").text.strip
    property[:neighborhood] = response.xpath("//header[@class='entry-header']/h5").text.strip

    # Initialize floor_plans
    property[:floorPlans] = []

    # Address
    property[:address] = response.xpath("//div[@class='col-md-6']/p").text.strip.gsub("\n", ", ") 

   # City name
   #  property[:city] = city_name(entry) # response.xpath("//div[@class='propertyAddressContainer']/h2/span[2]").text.strip
   #  # property[:cityId] = city_id(property[:city], property[:state])
   #  property[:cityId] = city_id(entry)

   #  # State name
    property[:state] = response.xpath("//div[@class='col-md-6']/p").text.strip.split("\n")[1].strip.split(" ")[1]

   #  # zip code
    property[:zip] = response.xpath("//div[@class='col-md-6']/p").text.strip.split("\n")[1].strip.split(" ")[2].to_i
    # property[:name1] = response.xpath("(//div[@class='unit'])").text
    floor_plans_url = response.xpath("//div[@class='rm-listings-container']/script").to_a[0].to_a[0][1].to_s

    # browser.click_link(floor_plans_url , wait: 2)
    # response = browser.current_response

    # http_response = HTTParty.get(floor_plans_url)
    # html = http_response.body
    
    request_to :parse_floor_plans, url: floor_plans_url, data: property

    # debugger

  end

  def parse_floor_plans(response, url:, data: {})
    response.xpath("//div[@class='\\\"unit\\\"']").each do |fp| 
      floor_plans = {}
      floor_plans[:name] = fp.xpath(".//div[@class='\\\"spec'][@spec-sm='']")[0].to_s.split("</span>")[1].gsub(/[^0-9]/, '')
      # floor_plans[:rentMin] = fp.xpath(".//div[@class='\\\"spec'][@spec-sm='']")[1].to_s.split("</span>")[1].gsub(/[^0-9]/, '').to_i

      floor_plans[:moveIn_script] = fp.xpath(".//div[@class='\\\"spec\\\"']/script")[0].children[0].text
      # availability_date_script = fp.xpath(".//div[@class='\\\"spec\\\"']/script")[0].children[0].to_s
      # browser.execute_script(availability_date_script)
      # floor_plans[:moveIn] = browser.current_rdataesponse

      floor_plans[:unit_type_script] = fp.xpath(".//div[@class='\\\"spec\\\"'][2]/script")[0].children[0].text #(Unit type rendering JS Script in string)
      floor_plans[:floor_plan_img_script] = fp.xpath(".//div[@class='\\\"spec\\\"'][3]/script")[0].text #(Unit type rendering JS Script in string)
      floor_plans[:features_script] = fp.xpath(".//div[@class='\\\"spec'][@spec-feature='']/script")[0].children[0].text #(Unit type rendering JS Script in string)
      floor_plans[:price_script] = fp.xpath(".//div[@class='\\\"spec'][@spec-sm='']/script")[0].children[0].text #(Unit type rendering JS Script in string)

      data[:floorPlans] << floor_plans
    end
    # debugger
  end



    # puts "HASH BEFORE: #{property}"
   #  send_item property
    # puts "HASH TO BE SAVED: #{property.to_json}"
   #  finish_entry(entry, property)
#   end

#   def all_cities
#     result = Scraper::Spark::Client.query(AllCities)               

#     puts "[INFO] All cities fetched successfully."
#     return result.original_hash["data"]["allCities"]
#   end


  # def initialize

  #   # @cities = all_cities
    
  #   super

  #   puts ">>>>>  Scraper Initialize Completed"
  # end

end
Scraper::Ppm.crawl!

# Sprape.crawl!
# Sprape.sign_in
# s = Sprape.new
# Sprape.crawl!

