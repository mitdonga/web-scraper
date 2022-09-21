module Queries
	module ScrapeEntries
    class Find < Queries::BaseQuery
			argument :scrape_id, Integer, required: true

			type [Types::ScrapeEntryType], null: false

			def resolve(scrape_id:)
				ScrapeEntry.includes(:link).where(scrape_id: scrape_id).order(:status)
			end
		end	
	end
end