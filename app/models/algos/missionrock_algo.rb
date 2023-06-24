module Algos::MissionrockAlgo

	def missionrock_scrape(response, url, data)
		browser.execute_script("document.getElementsByClassName('card-nav-btn')[0]?.click()")
		sleep 5
		response = browser.current_response

		entry = data[:scraper].url_hash.find {|u| u[:url] == url}

		property = {}
		fp_error = false

		# Property Name
		property[:name] = "Promontory Point Apartments"

		property[:neighborhood] = "Walnut Creek"

		# Initialize floor_plans
		property[:floorPlans] = []

		# Address
		property[:address] = "2250 Ridgepoint Dr Austin, TX 78754"

		# City name
		unless data[:property_scrape]
			property[:city] = city_name(entry, data[:scraper]) 
			property[:cityId] = city_id(entry, data[:scraper])
		else 
			property[:city] = scrape_property_city_name(data[:scraper])       #For Single Property Scrape
			property[:cityId] = scrape_property_city_id(data[:scraper])
		end

		# State name
		property[:state] = "Texas"

		# zip code
		property[:zip] = "78754"

		count = 0

		browser.current_response.xpath("//div[@class='flex card-container']").each do |fp|
			floor_plan = {}
			# Floor Plan Name
			# floor_plan[:name] = t.css(".modelName").text.strip
			floor_plan[:name] = fp.xpath(".//div[@class='flex xs12 pa-0 floorplan-title-content']//p")[0].text.strip
			# Floor Plan Min Rent
			rent_min = only_numbers(fp.xpath(".//div[@class='floorplan-labels']//p[@class='rate-display']")[0].text).to_i
			floor_plan[:rentMin] = rent_min
			# Floor Plan Max Rent
			rent_max = rent_min
			floor_plan[:rentMax] = rent_max > 0 ? rent_max : rent_min
			# Floor Plan Type / Bed
			floor_plan[:bed] = parse_bed(fp.xpath(".//div[@class='flex xs12 pa-0 floorplan-title-content']/p/span")[0].text)
			# Floor Plan Baths
			floor_plan[:bath] = parse_bath(fp.xpath(".//div[@class='flex xs12 pa-0 floorplan-title-content']/p/span")[1].text)
			# Floor Plan Size / Sq Feet
			floor_plan[:sqft] = parse_size(fp.xpath(".//div[@class='flex xs12 pa-0 floorplan-title-content']/p/span")[2].text).to_s
			floor_plan[:sqftMin] = floor_plan[:sqft].to_i
			floor_plan[:sqftMax] = floor_plan[:sqft].to_i
			floor_plan[:isAvailable] = Date.today
			# Floor Plan Deposit Amount
			floor_plan[:deposit] = nil
			floor_plan[:plan2dLink] = image_url_from_style(fp.xpath(".//div[@class='v-image__image v-image__image--contain']")&.first&.attributes["style"]&.value) if entry[:fetch_floorplan_images]
			# Floor Plan Availability
			# t.xpath(".//span[@class='detailsTextWrapper leaseDepositLabel']/span[3]").text  
			# Floor Plan Image
			# t.xpath(".//div[@class='floorPlanButtonImage']").to_s
			# if is_fetch_floorplan_images(entry)
			# if entry[:fetch_floorplan_images]
			# 	begin
			# 		var = fp.xpath(".//div[@class='column2']//div").to_a[0]["data-modelname"]
			# 		var2 = fp.xpath(".//div[@class='column2']//div").to_a[0]["data-rentalkey"]
			# 		browser.find(:xpath, "//div[@data-tab-content-id='all']//button[@data-modelname='#{var}'][@data-rentalkey='#{var2}'][@class='actionLinks js-priceGridModelfloorPlanButtons']").click
			# 		sleep 2
			# 		fp_img_url = browser.current_response.xpath("//ul[@id='photoList']//li[1]//div[@class='backgroundImageWrapper imgReady']").to_a[0]&.attributes["data-img-src"]&.value
			# 		floor_plan[:plan2dLink] = fp_img_url
			# 		browser.find(:xpath, "//div[@id='js-headerUtilities'][@class='headerUtilities']//button[@class='close'][@aria-label='close']").click
			# 		sleep 3
			# 	rescue => e
			# 		fp_error = var.nil? ? false : true
			# 		begin 
			# 			if browser.current_response.xpath("//div[@id='js-headerUtilities'][@class='headerUtilities']//button[@class='close'][@aria-label='close']")
			# 				browser.find(:xpath, "//div[@id='js-headerUtilities'][@class='headerUtilities']//button[@class='close'][@aria-label='close']").click
			# 			end
			# 			rescue => error
			# 				puts error
			# 			end
			# 		puts e
			# 	end
			# end
			if floor_plan[:bed]
				browser.execute_script("document.querySelectorAll('.primary-cta-btn.cta-btn.v-btn.v-btn--block.v-btn--large.v-btn--depressed.theme--light')[#{count}]?.click()")
				sleep 5
				count = count + 2
				floor_plan[:units] = []
				# Parse UNITS in the floor plan
				browser.current_response.xpath(".//div[@class='unit']").each do |u|
					unit = {}
					# Unit number / Appartment Number
					unit[:aptNo] = u.xpath(".//div[@class='unit-details unit-list']/p")[0].text.strip.gsub("Apartment ", "")
					# Unit rent / price
					unit[:price] = only_numbers(u.xpath(".//div[@class='unit-details unit-list']//p[@class='unit-rate-size']")[0].text).to_i
					# Unit Size / Sq Feet
					unit[:size] = floor_plan[:sqft].to_i
					# Unit available date 
					unit[:moveIn] = parse_date(u.xpath(".//div[@class='unit-details unit-list']/p[@class='availability-date']")[0].text)

					unit[:isAvailable] = !unit[:moveIn].blank?

					floor_plan[:units] << unit
				end
				property[:floorPlans] << floor_plan
				browser.execute_script("document.querySelector('.ma-0.v-btn.v-btn--flat.theme--light').click()")
				sleep 2
			end

			puts floor_plan
		end

		Link.find_by(url: entry[:url]).update(fetch_floorplan_images: false) unless fp_error	
		puts property

		send_item property
		
		finish_entry(entry, property, data[:scraper]) unless data[:property_scrape]

	rescue Exception => e
		puts "=========================== Scraping Error ============================"
		puts e
		puts "Something went wrong with this url: " + url
		puts "=========================== Scraping Error ============================"
	end

end