module Algos::GoodnightRanchRentcafeAlgo

	def goodnight_ranch_rentcafe_algo(response, url, data)
		template = data[:template]
		entry = data[:scraper].url_hash.find {|u| u[:url] == url}
		property = {}
		fp_error = false

		# Property Name
		property[:name] = template[:name]

		property[:neighborhood] = template[:neighborhood]

		# Initialize floor_plans
		property[:floorPlans] = []

		# Address
		property[:address] = template[:address]

		# City name
		unless data[:property_scrape]
			property[:city] = city_name(entry, data[:scraper]) 
			property[:cityId] = city_id(entry, data[:scraper])
		else 
			property[:city] = scrape_property_city_name(data[:scraper])       #For Single Property Scrape
			property[:cityId] = scrape_property_city_id(data[:scraper])
		end

		# State name
		property[:state] = template[:state]

		# zip code
		property[:zip] = template[:zip]
		count = 1
		eval(template[:floor_plans_loop]).each_with_index do |fp, index|
			browser.find(:xpath, "//ul[@id='floorplansLink']/li[#{index + 1}]").click
			response = browser.current_response

			# debugger if count == 2
			floor_plan = {}
			# Floor Plan Name

			floor_plan[:name] = eval(template[:fp_name])
			# Floor Plan Min Rent
			price = eval(template[:fp_rentMin])
			floor_plan[:rentMin] = price
			# Floor Plan Max Rent
			floor_plan[:rentMax] = price
			# Floor Plan Type / Bed

			floor_plan[:bed] = eval(template[:fp_bed])
			# Floor Plan Baths
			floor_plan[:bath] = eval(template[:fp_bath])
			# Floor Plan Size / Sq Feet
			floor_plan[:sqft] = eval(template[:fp_sqft])
			floor_plan[:sqftMin] = floor_plan[:sqft].to_i
			floor_plan[:sqftMax] = floor_plan[:sqft].to_i

			availability_element = eval(template[:fp_is_available])
			floor_plan[:isAvailable] = availability_element ? Date.today : nil
			# Floor Plan Deposit Amount
			floor_plan[:deposit] = nil
			if entry[:fetch_floorplan_images]
				floor_plan[:plan2dLink] = eval(template[:floor_plan_image])
			end
			floor_plan[:units] = []
			data[:floor_plan] = floor_plan
			data[:template] = template

			if floor_plan[:isAvailable]
				# browser.find(:xpath, ).click
				browser.find(:xpath, template[:units_button]).click
				response = browser.current_response
				floor_plan[:units] = parse_floor_plan_of_goodnight_ranch_rentcafe(response, data)
			end
			browser.execute_script("window.location.assign('#{url}')"); sleep 1
			property[:floorPlans] << floor_plan
			puts floor_plan
			count += 1
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

	def parse_floor_plan_of_goodnight_ranch_rentcafe(response, data)
		floor_plan = data[:floor_plan]
		template = data[:template]
		units = []
		
		eval(template[:units_loop]).each do |u|
			
			unit = {}
			# Unit number / Appartment Number
			unit[:aptNo] = eval(template[:aptNo])
			# Unit rent / price
			price = eval(template[:unit_price])
			unit[:price] = price[:rentMax]
			# Unit Size / Sq Feet
			unit[:size] = floor_plan[:sqft].to_i
			# Unit available date 
			unit[:moveIn] = template[:unit_moveIn] ? eval(template[:unit_moveIn]) : Date.today

			unit[:isAvailable] = !unit[:moveIn].blank?
			units << unit
		end
    return units
	rescue Exception => e
		puts "=========================== Scraping Error ============================"
		puts e
		puts "Something went while scraping the units from this url: " + url
		puts "=========================== Scraping Error ============================"
		return []
  end

end