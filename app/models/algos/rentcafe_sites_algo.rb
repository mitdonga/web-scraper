module Algos::RentcafeSitesAlgo

	def rentcafe_sites_scrape(response, url, data)
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
		response.xpath("//div[@class='pb-4 mb-2 col-12  col-sm-6 col-lg-4 fp-container']").each do |fp|
			# debugger if count == 2
			floor_plan = {}
			# Floor Plan Name
			floor_plan[:name] = fp.xpath(".//h2").text.strip
			# Floor Plan Min Rent
			price = parse_rent(fp.xpath(".//p[@class='font-weight-bold  mb-1 text-md']")[0].text.strip)
			floor_plan[:rentMin] = price[:rentMin]
			# Floor Plan Max Rent
			floor_plan[:rentMax] = price[:rentMax]
			# Floor Plan Type / Bed
			floor_plan[:bed] = parse_bed(fp.xpath(".//li[@class='list-inline-item mr-2']")[0].text.strip)
			# Floor Plan Baths
			floor_plan[:bath] = parse_bath(fp.xpath(".//li[@class='list-inline-item mr-2']")[1].text.strip)
			# Floor Plan Size / Sq Feet
			floor_plan[:sqft] = parse_size(fp.xpath(".//li[@class='list-inline-item w-100']")[0].text.strip).to_s
			floor_plan[:sqftMin] = floor_plan[:sqft].to_i
			floor_plan[:sqftMax] = floor_plan[:sqft].to_i

			availability_element = fp.xpath(".//a[@class='btn btn-primary btn-block btn-block  track-apply floorplan-action-button']")[0]
			floor_plan[:isAvailable] = availability_element&.text&.strip&.include?("Availability") ? Date.today : nil
			unit_url = floor_plan[:isAvailable] ? availability_element.attributes["href"].value : nil

			# Floor Plan Deposit Amount
			floor_plan[:deposit] = nil
			if entry[:fetch_floorplan_images]
				image_link = fp.xpath(".//img")[0]&.attributes["data-src"]&.value	
				floor_plan[:plan2dLink] = image_link ? image_link : fp.xpath(".//img")[0]&.attributes["src"]&.value	
			end
			floor_plan[:units] = []
			data[:floor_plan] = floor_plan
			if unit_url
				unit_url = template[:url] + unit_url
				units = request_to :parse_floor_plan_of_rentcafe_sites, url: unit_url, data: data
				floor_plan[:units] = units
			end

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

	def parse_floor_plan_of_rentcafe_sites(response, url:, data: {})
		template = data[:template]
		floor_plan = data[:floor_plan]
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