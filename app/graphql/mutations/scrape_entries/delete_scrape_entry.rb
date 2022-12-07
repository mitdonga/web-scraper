module Mutations::ScrapeEntries
	class DeleteScrapeEntry <	Mutations::BaseMutation
		argument :scrape_id, Integer, required: true
		argument :scrape_entry_id, Integer, required: true

		field :scrape, Types::ScrapeType, null: false
		field :message, String, null: false
		field :errors, [String], null: false

		def resolve(scrape_id:, scrape_entry_id:)

			scrape = Scrape.find(scrape_id)
			scrape_entry = scrape.scrape_entries.find(scrape_entry_id)

			if scrape_entry.destroy
				return { scrape: scrape, message: "Scrape Entry Deleted Successfully", errors: [] }
			end

		rescue Exception => e
      return { message: "Oops, something went wrong!", errors: [e.message] }
		end
	end
end