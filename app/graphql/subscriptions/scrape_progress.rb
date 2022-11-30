module Subscriptions
	class ScrapeProgress < GraphQL::Schema::Subscription

		field :scrape, Types::ScrapeType, null: true

	end
end