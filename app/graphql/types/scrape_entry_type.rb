# frozen_string_literal: true

module Types
  class ScrapeEntryType < Types::BaseObject
    field :id, ID, null: false
    field :scrape_id, Integer, null: false
    field :link_id, Integer, null: false
    field :link, Types::LinkType, null: false
    # field :status, Types::StatusType
    # field :retries, Integer
    field :notes, String
    # field :raw_hash, String
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
