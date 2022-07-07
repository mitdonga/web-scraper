# frozen_string_literal: true

module Types
  class SummaryType < Types::BaseObject
    field :city_count, Integer, null: true
    field :link_count, Integer, null: true
    field :scrape_count, Integer, null: true
    # field :city_count, Integer, null: false
    # field :name, String
    # field :scheduled_at, GraphQL::Types::ISO8601DateTime
    # field :started_at, GraphQL::Types::ISO8601DateTime
    # field :ended_at, GraphQL::Types::ISO8601DateTime
    # field :status, Types::StatusType
    # field :retries, Integer
    # field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    # field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    # field :scrape_entries, [Types::ScrapeEntryType], null: false
  end
end
