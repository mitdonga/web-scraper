# frozen_string_literal: true

module Types
  class LinkType < Types::BaseObject
    field :id, ID, null: false
    field :name, String
    field :url, String
    field :units_url, String
    field :s_id, Integer
    field :city_id, Integer, null: false
    field :city, Types::CityType, null: false
    field :fetch_floorplan_images, Boolean, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :discarded_at, GraphQL::Types::ISO8601DateTime, null: true
		field :part_of_scrape, Integer, null: false
		field :success, Boolean, null: true
		field :notes, String, null: true

		def part_of_scrape
			ScrapeEntry.where(link_id: object.id).count
		end
  end
end
