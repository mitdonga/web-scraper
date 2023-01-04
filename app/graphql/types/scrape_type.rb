# frozen_string_literal: true

module Types
  class ScrapeType < Types::BaseObject
    field :id, ID, null: false
    field :name, String
    field :scheduled_at, GraphQL::Types::ISO8601DateTime
    field :started_at, GraphQL::Types::ISO8601DateTime
    field :ended_at, GraphQL::Types::ISO8601DateTime
    field :status, Types::StatusType
    # field :retries, Integer
    field :frequency, Types::FrequencyType
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :scrape_entries, [Types::ScrapeEntryType], null: false
    field :scrape_histories, [Types::ScrapeHistoryType], null: false
    field :discarded_at, GraphQL::Types::ISO8601DateTime, null: true
    field :avg_run_time, Integer, null: true

    field :scrape_entries_count, Integer
    # field :completed_scrape_entries_count, Integer
    # field :canceled_scrape_entries_count, Integer

    def scrape_entries_count
      object.scrape_entries.count
    end

    # def completed_scrape_entries_count
    #   object.scrape_entries.completed.count
    # end

    # def canceled_scrape_entries_count
    #   object.scrape_entries.canceled.count
    # end
   
  end
end

