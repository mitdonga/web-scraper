module Queries
  module Summary
    class Summary < Queries::BaseQuery
      # argument :status, [Types::StatusType], required: false

      type Types::SummaryType, null: false
  
      def resolve
        {city_count: City.count, link_count: Link.kept.count, scrape_count: Scrape.count}
      end
    end

  end
end