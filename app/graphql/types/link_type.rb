# frozen_string_literal: true

module Types
  class LinkType < Types::BaseObject
    field :id, ID, null: false
    field :name, String
    field :url, String
    field :s_id, Integer
    field :city_id, Integer, null: false
    field :city, Types::CityType, null: false
    field :algo_id, Integer, null: false
    field :algo, Types::AlgoType, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :discarded_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
