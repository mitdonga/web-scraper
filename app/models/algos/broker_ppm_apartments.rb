module Algos::BrokerPpmApartments
	def broker_ppm_apartments(response, url, data)
		entry = data[:scraper].url_hash.find {|u| u[:url] == url}

		response = Nokogiri::HTML(URI.open(url))
		
		properties = response.xpath("//h2").to_a.map(&:text)

		response.xpath("//div[@class='listings']").each_with_index do |res, index|

			property = {}
			property[:name] = properties[index]
			property[:address] = properties[index]
			debugger
			property[:neighborhood] = "Unknown"
			property[:floorPlans] = []
			property[:address] = []

			unless data[:property_scrape]
				property[:city] = city_name(entry, data[:scraper]) 
				property[:cityId] = city_id(entry, data[:scraper])
			else 
				property[:city] = scrape_property_city_name(data[:scraper])
				property[:cityId] = scrape_property_city_id(data[:scraper])
			end

			units_url = res.xpath(".//script").to_a.first.attributes["src"].value
			floor_plans = request_to :parse_units, url: units_url
			property[:floorPlans] = floor_plans

			send_item property
			finish_entry(entry, property, data[:scraper]) unless data[:property_scrape]
		end

		# Link.find_by(url: entry[:url]).update(fetch_floorplan_images: false) unless fp_error	
	rescue Exception => e
		puts "=========================== Scraping Error ============================"
		puts e
		puts "Something went wrong with this url: " + url
		puts "=========================== Scraping Error ============================"
	end

	def parse_units(response, url:, data: {})
		units = []
		response.xpath(".//tr[@class='\\\"search_result\\\"']").each do |row|
			cells = row.xpath(".//td").map { |c| c.text}
			json = {}
			unit = {}
			cells.each_with_index do |cell, index|
				key, value = *cell.split(":")
				if key == "Available"
					json[key] = row.xpath(".//td")[index].children.to_a.last.text.strip
				else
					json[key] = value.strip
				end
			end
			unit[:aptNo] = parse_aptno(json["Unit"])
			unit[:price] = parse_amount(json["Price"])
			unit[:size] = parse_size(json["Square Footage"])
			unit[:moveIn] = parse_movein(json["Available"])
			unit[:isAvailable] = !unit[:moveIn].blank?
			unit[:floor_plan] = json["Type"]
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
			floor_plan[:bed] = parse_bed_from_floor_plan(fp)
			floor_plan[:bath] = parse_bath_from_floor_plan(fp)
			floor_plan[:sqft] = nil
			floor_plan[:sqftMin] = units_arr.pluck(:size).min
			floor_plan[:sqftMax] = units_arr.pluck(:size).max
			floor_plan[:isAvailable] = DateTime.now
			floor_plan[:units] = units_arr.map {|unit| unit.except(:floor_plan)}
			floor_plans << floor_plan
		end
		return floor_plans
	end
end