
module Types
  class ScrapeEntryHistoryType < Types::BaseObject
    field :id, ID, null: false
    field :scrape_history_id, Integer, null: false
    field :scrape_entry_id, Integer, null: false
		field :scrape_entry, Types::ScrapeEntryType, null: false
    field :status, Types::StatusType
    field :retries, Integer
    field :notes, String
    field :raw_hash, String
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

  end
end
