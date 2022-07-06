module Types
  # Define all available GraphQL subscriptions
  class SubscriptionType < Types::BaseObject
    field :scrape_progress, subscription: Subscriptions::ScrapeProgress, null: false

    # def scrape_progress; end
    # Book subscriptions
    # field :book_updated, subscription: Subscriptions::BookModified
    # field :book_deleted, subscription: Subscriptions::BookModified
  end
end