module Queries
  module Scrapes
    class AllScrapes < Queries::BaseQuery
      # argument :status, [Types::StatusType], required: false

      type [Types::ScrapeType], null: false
  
      def resolve()
        Scrape.kept.includes(:scrape_entries, :scrape_histories).all.reverse
      end
    end
		
    # class Scrapes < Queries::BaseQuery
    #   # argument :status, [Types::StatusType], required: false

    #   type [Types::ScrapeType], null: false
  
    # def resolve()
    #     status.blank? ? 
    #       Scrape.includes(:scrape_entries, :scrape_histories).all : 
    #       Scrape.includes(:scrape_entries, :scrape_histories)
    #   end
    # end

    class Find < Queries::BaseQuery
      argument :search, String, required: true

      type [Types::ScrapeType], null: false

      def resolve(search:)
        Scrape.includes(:scrape_entries, :scrape_histories).where("LOWER(name) like '%#{search.downcase}%'")
      end
    end

  end
end