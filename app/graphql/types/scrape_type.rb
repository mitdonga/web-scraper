# frozen_string_literal: true

module Types
  class ScrapeType < Types::BaseObject
    field :id, ID, null: false
    field :name, String
    field :scheduled_at, GraphQL::Types::ISO8601DateTime
    field :started_at, GraphQL::Types::ISO8601DateTime
    field :ended_at, GraphQL::Types::ISO8601DateTime
    field :status, Types::StatusType
    field :retries, Integer
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :scrape_entries, [Types::ScrapeEntryType], null: false
  end
end
