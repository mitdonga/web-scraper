module Mutations::Scrapes
	class ScrapeCancel < Mutations::BaseMutation

		argument :scrapeId, Integer, required: true

		field :message, String, null: true
		field :errors, [String], null: true

		def resolve(scrapeId:)
			scrape = Scrape.find(scrapeId)
			inprogress_scrape_history = scrape.scrape_histories.find_by(status: "inprogress")
			if inprogress_scrape_history
				inprogress_scrape_history.cancel
					return {message: "Scrape #{scrape.id}: #{scrape.name} cancelled successfully"}
			else
					return {message: "Scrape #{scrape.name} is not running right now"}
			end
		rescue Exception => e
			puts e.message
			puts e.backtrace.join("\n")
			return { message: "Oops, something went wrong!", errors: [e.message] }
		end

	end
end