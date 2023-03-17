module Algos::RentcafeAlgo
	
	def rentcafe_property_scrape(response, url, data)
		begin
			entry = data[:scraper].url_hash.find {|u| u[:url] == url}

			# return 0 unless scrape_entry = start_entry(entry)

			property = {}
			fp_error = false
			
			if entry[:units_url].nil?
				begin
					if response.xpath("//button[@id='apply-now-top']").any?
						units_url = response.xpath("//button[@id='apply-now-top']")&.first[:onclick]&.gsub("window.open('",'')&.gsub("')", '')
						if units_url&.length > 5
							Link.find_by(url: url).update(units_url: units_url)
						else
							Link.find_by(url: url).update(success: false, notes: "No units_url found on primary page")
							return 
						end
					end
				rescue Exception => e
					Link.find_by(url: url).update(success: false, notes: "No units_url found on primary page")
					puts e.message
					return
				end
			end

			# debugger

			property[:name] = response.xpath("//h2[@class='property-title']").text
			property[:neighborhood] = response.xpath("//section[@class='internall-linking-nearby-nhoods']//ul/li[1]")&.first&.text&.strip&.gsub("Apartments for Rent in ", "")
			property[:address] = response.xpath("//div[@class='property-address']")&.first&.children[1]&.children[0]&.text	+
													response.xpath("//div[@class='property-address']")&.first&.children[3]&.children[0]&.text +
													response.xpath("//div[@class='property-address']")&.first&.children[4]&.children[0]&.text + " " +
													response.xpath("//div[@class='property-address']")&.first&.children[6]&.children[1]&.text

			unless data[:property_scrape]
				property[:city] = city_name(entry, data[:scraper]) 
				property[:cityId] = city_id(entry, data[:scraper])
			else 
				property[:city] = scrape_property_city_name(data[:scraper])         #For Single Property Scrape
				property[:cityId] = scrape_property_city_id(data[:scraper])
			end

			property[:state] = response.xpath("//div[@class='property-address']/span[3]")&.first&.text
			property[:zip] = response.xpath("//div[@class='property-address']/span[4]")&.first&.text&.strip

			browser.execute_script("document.getElementById('viewMoreFps').click()")
			response = browser.current_response

			puts property

			property[:floorPlans] = []
			response.xpath("//div[@class='fp-item']").each do |fp|
				floor_plan = {}
				floor_plan[:name] = fp.xpath(".//div[@class='fp-info']/b").text&.strip

				floor_plan[:rentMin] = parse_rent(fp.xpath(".//div[@class='fp-price-info']/span[@class='fp-price']").text)[:rentMin]
				floor_plan[:rentMax] = parse_rent(fp.xpath(".//div[@class='fp-price-info']/span[@class='fp-price']").text)[:rentMax]
				floor_plan[:bed] = parse_bed(fp.xpath(".//li[@class='fp-criterion1']").text.downcase)
				floor_plan[:bath] = parse_bath(fp.xpath(".//li[@class='fp-criterion2']").text.downcase)
				floor_plan[:sqft] = fp.xpath(".//div[@class='fp-info']/div[@class='fp-area']").text.gsub(/[^0-9]/, '')
				floor_plan[:sqftMin] = 0
				floor_plan[:sqftMax] = 0
				floor_plan[:isAvailable] = fp.xpath(".//div[@class='fp-price-info']/span[@class='fp-available']").text.length > 0 ? "Available" : "Not Available"
				floor_plan[:deposit] = nil
				floor_plan[:plan2dLink] = nil
				floor_plan[:units] = []

				if entry[:fetch_floorplan_images]
					begin
						if !fp.xpath(".//div[@class='fp-thumb']/img").text.include? "no_img.jpg"
							fp_btn_id = fp.xpath(".//div[@class='fp-action']/button[@data-target='#fp-details-modal']").first["id"]
							browser.find(:xpath, "//button[@id='#{fp_btn_id}']").click
							sleep 6
							fp_img_obj = browser.current_response.xpath(".//div[@class='item modal-item']/img")[0]
							floor_plan[:plan2dLink] = fp_img_obj&.attributes["data-url"]&.value
							browser.find(:xpath, "//div[@class='fp-details-modal-close']/button[@class='close']").click
						end
					rescue Exception => e
						fp_error = fp_btn_id.nil? ? false : true
						puts e.message
					end
				end

				property[:floorPlans] << floor_plan
				puts floor_plan
			end

			puts property

			scrape_url = entry[:units_url] ? entry[:units_url] : units_url

			# request_to :rentcafe_fetch_floorplan_units, url: absolute_url(scrape_url, base: scrape_url), data: { property: property, scraper: data[:scraper], entry: entry, property_scrape: data[:property_scrape], fp_error: fp_error }
			# request_to :rentcafe_fetch_floorplan_units, url: entry[:units_url] ? entry[:units_url] : units_url, data: { property: property, scraper: data[:scraper], entry: entry, property_scrape: data[:property_scrape], fp_error: fp_error }
			in_parallel(:rentcafe_fetch_floorplan_units, [scrape_url], threads: 2, delay: rand(2..5), config: config, data: { property: property, scraper: data[:scraper], entry: entry, property_scrape: data[:property_scrape], fp_error: fp_error })

		rescue Exception => e
			puts "=========================== Scrping Error ============================"
			puts e
			puts "Something went wrong with this url: " + url
			puts "=========================== Scrping Error ============================"
		end
	end

	def rentcafe_fetch_floorplan_units(response, url:, data: {})
		property = data[:property]
		floor_plans = []
		count = 0

		response.xpath("//table").each do |fp|
			floor_plan = {}
			floor_plan[:name] = response.xpath("//h3")[count].text&.strip

			floor_plan[:units] = []
			fp.xpath(".//tbody/tr").each do |tr|
				unit = {}
				unit[:aptNo] = tr.xpath(".//td[@data-label='Apartment']").text.gsub("#", '')&.strip
				price_range = tr.xpath(".//td[@data-label='Rent']").text.split("-")
				price = price_range[1] if price_range.size == 2
				price = price_range[0] if price_range.size == 1
				unit[:price] = price.gsub(/[^0-9]/, '').to_i

				unit[:size] = tr.xpath(".//td[@data-label='Sq.Ft.']").text.to_i
				unit[:moveIn] = parse_movein(tr.xpath(".//button").to_a[0]&.attributes["onclick"]&.value)
				unit[:isAvailable] = !unit[:moveIn].blank?
				floor_plan[:units] << unit
			end

			floor_plans << floor_plan
			count += 1
		end
		
		final_property = rentcafe_join_units(floor_plans, property)
		Link.find_by(url: data[:entry][:url]).update(fetch_floorplan_images: false) unless data[:fp_error]	

		puts "========================= Final RentCafe Property ========================="
		puts final_property

		send_item final_property

		finish_entry(data[:entry], final_property, data[:scraper]) unless data[:property_scrape]
	end

	def rentcafe_join_units(floor_plans, property) 

		result_property = property
		fps = []
		property[:floorPlans].each do |fp|
			floor_plan = fp
			floor_plan[:units] = rentcafe_get_units(fp, floor_plans)
			fps << floor_plan
		end

		result_property[:floorPlans] = fps

		return result_property
	end

	def rentcafe_get_units(floor_plan, floor_plans)
		floor_plans.each do |fp|
			return fp[:units] if fp[:name].downcase.include? floor_plan[:name].downcase
		end
		return []
	end

end