module Subscriptions
  class ScrapeProgress < GraphQL::Schema::Subscription
    argument :scrape_id, ID, required: true

    field :progress, Integer, null: false

    def resolve(scrape_id:)
      {data: {progress: rand(1..100)}}
    end
  end
end