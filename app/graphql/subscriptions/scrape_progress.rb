module Subscriptions
	class ScrapeProgress < GraphQL::Schema::Subscription

		field :scrape_history, Types::ScrapeHistoryType, null: true

	end
end