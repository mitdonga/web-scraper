module Mutations::Scrapes
	class EditLinks <	Mutations::BaseMutation
		argument :scrape_id, Integer, required: true
		argument :city_id, Integer, required: true
		argument :add_links_array, [String], required: false
		argument :remove_links_array, [String], required: false
		argument :remove_link_ids_array, [Integer], required: false
		argument :links_file, Types::FileType, required: false

		field :scrape, Types::ScrapeType, null: true
		field :message, String, null: true
		field :errors, [String], null: true

		def resolve(scrape_id:, city_id:, add_links_array: [], remove_links_array: [], remove_link_ids_array: [], links_file: nil)
			scrape = Scrape.find(scrape_id)
			links_created = 0
			added_scrape_entries = 0

			if add_links_array.any? 
				add_links_array.each do |link|
					url = URI.extract(link, /http(s)?/)[0]
					if url
						url = url[-1] == "/" ? url : url.insert(-1, "/")
						existing_link = Link.find_by("url LIKE ?", "%#{url}%")
						unless existing_link
							new_link = Link.create(url: url, city_id: city_id)
							puts new_link.url
							links_created += 1
							scrape.scrape_entries.create(link: new_link) 
							added_scrape_entries += 1
						else
							unless scrape.scrape_entries.find_by(link: existing_link)
								scrape.scrape_entries.create(link: existing_link) 
								added_scrape_entries += 1
							end
						end
					end
				end
			end

			if links_file
				data = Roo::Spreadsheet.open(links_file) # open spreadsheet
				headers = data.row(1) # get header row

				data.each_with_index do |row, idx|
					
					next if idx == 0 # skip header
					link_data = Hash[[headers, row].transpose]

					url = valid_url(link_data['URLs'])
					existing_link = Link.find_by("url LIKE ?", "%#{url}%")

					unless existing_link
						units_url = valid_url(link_data['UNITS URLs'])
						link = Link.new(city_id: city_id, url: url, units_url: units_url)
						
						if link.save
							links_created += 1
							scrape.scrape_entries.create(link: link)
							added_scrape_entries += 1
						end
					else
						unless scrape.scrape_entries.find_by(link: existing_link)
							scrape.scrape_entries.create(link: existing_link) 
							added_scrape_entries += 1
						end
					end
				end
			end

      return { scrape: scrape, message: "Success! Added scrape entries: #{added_scrape_entries}, Added New Links: #{links_created}", errors: [] }
		rescue Exception => e
      return { message: "Oops, something went wrong!", errors: [e.message] }
		end

		def valid_url(url)
			return nil if url.nil?
			url[-1] == "/" ? url : url.insert(-1, "/")
		end

	end
end