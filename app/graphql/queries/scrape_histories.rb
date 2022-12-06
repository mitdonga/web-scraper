module Queries
  module ScrapeHistories
    class Find < Queries::BaseQuery

			argument :id, Integer, required: false
			argument :status, String, required: false

			type Types::ScrapeHistoryType, null: true

			def resolve(id: nil, status: nil)
				if id
					ScrapeHistory.includes(scrape_entry_histories: [scrape_entry: :link]).find(id)
				elsif status
					ScrapeHistory.find_by(status: status)
				end
			end

		end
	end
end