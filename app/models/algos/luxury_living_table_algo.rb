module Algos::LuxuryLivingTableAlgo

	def luxury_living_table_scrape(response, url, data)
		template = data[:template]
		entry = data[:scraper].url_hash.find {|u| u[:url] == url}

		property = {}

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
		units = []

		units_url = response.xpath("//div[@id='nestio-iframe-pym']/iframe").to_a.first.attributes["src"].value
		browser.execute_script("window.location.assign('#{units_url}')"); sleep 2
		response = browser.current_response

		eval(template[:units_loop]).each do |u|
			unit = {}
			# Unit number / Appartment Number
			unit[:aptNo] = eval(template[:aptNo])
			# Unit rent / price
			price = eval(template[:unit_price])
			unit[:price] = price[:rentMax]
			# Unit available date 
			unit[:moveIn] = template[:unit_moveIn] ? eval(template[:unit_moveIn]) : Date.today

			unit[:isAvailable] = !unit[:moveIn].blank?
			unit[:floor_plan] = eval(template[:fp_name])
			unit[:bath] = eval(template[:fp_bath])

			if entry[:fetch_floorplan_images]
				unit[:plan2dLink] = eval(template[:floor_plan_image] || "nil")
			else
				unit[:plan2dLink] = nil
			end

			if units.last && units.last[:floor_plan] == unit[:floor_plan]
				unit[:size] = units.last[:size]
			else
				browser.execute_script("window.location.assign('#{url}#{u.values[0]}')"); sleep 1;
				response = browser.current_response
				
				floor_plan_url = response.xpath(".//div[@id='nestio-iframe-pym']/iframe")[0].values[0]
				browser.execute_script("window.location.assign('#{floor_plan_url}')"); sleep 2;
				response = browser.current_response

				unit[:size] = eval(template[:fp_sqft])
			end
			units << unit
		end

		floor_plans = []
		fp_hash = units.group_by {|unit| unit[:floor_plan]}
		fp_hash.keys.each do |fp|
			floor_plan = {}
			units_arr = fp_hash[fp]
			floor_plan[:name] = fp
			floor_plan[:rentMin] = units_arr.pluck(:price).min
			floor_plan[:rentMax] = units_arr.pluck(:price).max
			floor_plan[:bed] = parse_bed_new(fp)
			floor_plan[:bath] = units_arr[0][:bath]
			floor_plan[:sqft] = nil
			floor_plan[:sqftMin] = units_arr.pluck(:size).min
			floor_plan[:sqftMax] = units_arr.pluck(:size).max
			floor_plan[:isAvailable] = DateTime.now
			floor_plan[:plan2dLink] = units_arr[0][:plan2dLink]
			floor_plan[:units] = units_arr.map {|unit| unit.except(:floor_plan, :bath, :plan2dLink)}
			floor_plans << floor_plan
		end
		property[:floorPlans] = floor_plans

		Link.find_by(url: entry[:url]).update(fetch_floorplan_images: false)
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