module Mutations::Scrapes

	class ScrapeCreate < Mutations::BaseMutation

		argument :name, String, required: true
		argument :link_ids, [Integer], required: false
		argument :links, [String], required: false
		argument :frequency, String, required: true
		argument :scheduled_at, String, required: false
		argument :links_file, Types::FileType, required: false
		argument :city_id, Integer, required: false

		field :scrape, Types::ScrapeType, null: true
		field :message, String, null: true
		field :errors, [String], null: true

		def resolve(name:, link_ids: [], frequency:, scheduled_at: Time.now, links_file: nil, city_id: nil, links: [])

			if Scrape.find_by(name: name).blank?
				scrape = Scrape.new(name: name, scheduled_at: scheduled_at.to_datetime, frequency: frequency)
				
				added_links = 0
				created_links = 0

				if scrape.save 

					if link_ids.any?
						link_ids.each do |link_id|
							if Link.kept.find(link_id)
								scrape.scrape_entries << ScrapeEntry.new(link_id: link_id)
								added_links += 1
							end
						end
					end

					city = City.find(city_id) if links_file || links.any?

					if links_file && city
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
									created_links += 1
									scrape.scrape_entries.create(link: link)
									added_links += 1
								end
							else
								# unless scrape.scrape_entries.find_by(link: existing_link)
									scrape.scrape_entries.create(link: existing_link) 
									added_links += 1
								# end
							end
						end 
					end

					if links.any? && city
						links.each do |link|
							url = URI.extract(link, /http(s)?/)[0]
							if url
								url = url[-1] == "/" ? url : url.insert(-1, "/")
								existing_link = Link.find_by("url LIKE ?", "%#{url}%")
								unless existing_link
									new_link = Link.new(url: url, city: city)
									if new_link.save
										created_links += 1
										scrape.scrape_entries.create(link: new_link) 
										added_links += 1
									end
								else
									# unless scrape.scrape_entries.find_by(link: existing_link)
										scrape.scrape_entries.create(link: existing_link) 
										added_links += 1
									# end
								end
							end
						end
					end

				else
					{message: "Error while creating scrape",
						errors: scrape.errors.full_messages
					}
				end

				{	scrape: scrape,
					message: "New scrape #{scrape.name} created successfully, #{added_links} links added, #{created_links} new links created",
					errors: []
				}

			else
				{
					message: "Duplicate scrape name, please enter a different one",
					errors: ["Duplicate scrape name, please enter a different one"]
				}
			end

		rescue Exception => e
			puts e.message
			puts e.backtrace.join("\n")
			return { message: "Oops, something went wrong!", errors: [e.message] }
		end

		def valid_url(url)
			return nil if url.nil?
			url[-1] == "/" ? url : url.insert(-1, "/")
		end

  end

end