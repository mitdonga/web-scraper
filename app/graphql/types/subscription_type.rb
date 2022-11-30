module Types
  # Define all available GraphQL subscriptions
  class SubscriptionType < Types::BaseObject

		# description "The GraphQL subscription"	
    field :scrape_progress, subscription: Subscriptions::ScrapeProgress, null: false
    # field :scrape_progress, Types::ScrapeType, null: false

		# def scrape_progress 
		# 	object
		# end


    # def scrape_progress; end
    # Book subscriptions
    # field :book_updated, subscription: Subscriptions::BookModified

    # field :scrape_progress, subscription: Subscriptions::ScrapeProgress, null: false

  end
end