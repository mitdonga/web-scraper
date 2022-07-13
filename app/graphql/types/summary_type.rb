# frozen_string_literal: true

module Types
  class SummaryType < Types::BaseObject
    field :city_count, Integer, null: true
    field :link_count, Integer, null: true
    field :scrape_count, Integer, null: true
  end
end
