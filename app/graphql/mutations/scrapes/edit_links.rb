module Mutations::Scrapes
	class EditLinks <	Mutations::BaseMutation
		argument :scrape_id, Integer, required: true
		argument :city_id, Integer, required: true
		argument :add_links_array, [String], required: false
		argument :remove_links_array, [String], required: false
		argument :remove_link_ids_array, [Integer], required: false

		field :scrape, Types::ScrapeType, null: true
		field :message, String, null: true
		field :errors, [String], null: true

		def resolve(scrape_id:, city_id:, add_links_array: [], remove_links_array: [], remove_link_ids_array: [])
			scrape = Scrape.find(scrape_id)
			links_created = 0
			added_scrape_entries = 0

			add_links_array.each do |link|
				url = URI.extract(link, /http(s)?/)[0]
				if url
					url = url[-1] == "/" ? url : url.insert(-1, "/")
					existing_link = Link.find_by("url LIKE ?", "%#{url}%")
					unless existing_link
						new_link = Link.create(url: url, city_id: city_id, algo_id: 1)
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

      return { scrape: scrape, message: "Success! Added scrape entries: #{added_scrape_entries}, Added New Links: #{links_created}", errors: [] }
		rescue Exception => e
      return { message: "Oops, something went wrong!", errors: [e.message] }
		end
	end
end