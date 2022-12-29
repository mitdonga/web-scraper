module Mutations::Scrapes
	class ScrapeDiscard < Mutations::BaseMutation
		argument :scrape_id, Integer, required: true
		argument :discard, Boolean, required: true

		field :scrape, Types::ScrapeType, null: false
		field :message, String, null: false
		field :errors, [String], null: false

		def resolve(scrape_id:, discard:)
			scrape = Scrape.find(scrape_id)

			if (discard && scrape.discard) || (!discard && scrape.undiscard)
				return { scrape: scrape, message: "Scrape #{discard ? "discarded" : "undiscarded"} successfully", errors: [] }
			else
				return { message: "Oops, something went wrong!", errors: ["Oops, something went wrong!"] }
			end
		rescue Exception => e
			return { message: "Oops, something went wrong!", errors: [e.message] }
	 	end

	end
end