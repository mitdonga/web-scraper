# frozen_string_literal: true

module Types
  class ScrapeHistoryType < Types::BaseObject
    field :id, ID, null: false
		field :scrape_id, Integer, null: false
		field :name, String
    field :started_at, GraphQL::Types::ISO8601DateTime
    field :ended_at, GraphQL::Types::ISO8601DateTime
    field :status, Types::StatusType
    field :retries, Integer
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :scrape_entry_histories, [Types::ScrapeEntryHistoryType], null: false

    field :scrape_entries_count, Integer, null: false
    field :completed_scrape_entries_count, Integer, null: false
    field :canceled_scrape_entries_count, Integer, null: false

    def scrape_entries_count
      object.scrape_entry_histories.count
    end

    def completed_scrape_entries_count
      object.scrape_entry_histories.completed.count
    end

    def canceled_scrape_entries_count
      object.scrape_entry_histories.canceled.count
    end
		
		def name
			object.scrape.name
		end
  end
end

