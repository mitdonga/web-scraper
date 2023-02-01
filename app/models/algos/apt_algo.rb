module Algos::AptAlgo

	def apartments_property_scrape(response, url, data)
		entry = data[:scraper].url_hash.find {|u| u[:url] == url}
		# unless entry
		# 	puts "[ERROR] Entry Not Found"
		# 	return 0
		# end
		# start_entry(entry) unless data[:property_scrape]

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
			property[:city] = city_name(entry, data[:scraper]) 
			property[:cityId] = city_id(entry, data[:scraper])
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
      floor_plan[:isAvailable] = parse_date(fp.xpath(".//span[@class='detailsTextWrapper']//span[@class='availabilityInfo']").text)
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

    send_item property
		
    finish_entry(entry, property, data[:scraper]) unless data[:property_scrape]

	end

end