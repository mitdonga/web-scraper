module Algos::LandmarkAlgo

	def landmark_scrape(response, url, data)

		entry = data[:scraper].url_hash.find {|u| u[:url] == url}

		property = {}
		fp_error = false

		# Property Name
		property[:name] = "Landmark Conservancy"

		property[:neighborhood] = "Downtown"

		# Initialize floor_plans
		property[:floorPlans] = []

		# Address
		property[:address] = "9301 Old Bee Caves Road, Austin, TX 78735"

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
		property[:zip] = "78735"
		count = 1
		response.xpath("//div[@class='pb-4 mb-2 col-12  col-sm-6 col-lg-4 fp-container']").each do |fp|
			# debugger if count == 4
			floor_plan = {}
			# Floor Plan Name
			floor_plan[:name] = fp.xpath(".//h2").text.strip
			# Floor Plan Min Rent
			rent_min = only_numbers(fp.xpath(".//p[@class='font-weight-bold  mb-1 text-md']")[0].text.strip).to_i
			floor_plan[:rentMin] = rent_min
			# Floor Plan Max Rent
			rent_max = rent_min
			floor_plan[:rentMax] = rent_max > 0 ? rent_max : rent_min
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

			if unit_url
				unit_url = 'https://www.landmarkconservancy.com' + unit_url
				units = request_to :parse_floor_plan, url: unit_url
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

	def parse_floor_plan(response, url:, data: {})
		units = []
		response.xpath(".//tbody/tr").each do |u|
			unit = {}
			# Unit number / Appartment Number
			unit[:aptNo] = u.xpath(".//td[@class='td-card-name']").text.strip.gsub("Apartment: ", "")
			# Unit rent / price
			unit[:price] = only_numbers(u.xpath(".//td[@class='td-card-rent']").text.strip).to_i
			# Unit Size / Sq Feet
			unit[:size] = only_numbers(u.xpath(".//td[@class='td-card-sqft']").text.strip).to_i
			# Unit available date 
			unit[:moveIn] = prase_date_mddyyyy(u.xpath(".//td[@class='td-card-available']").text.strip.gsub("Date:", ""))

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