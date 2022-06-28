module Queries
  module Scrapes
    class Scrapes < Queries::BaseQuery
      argument :status, [Types::StatusType], required: false

      type [Types::ScrapeType], null: false
  
      def resolve(status:["scheduled"])
        status.blank? ? 
          Scrape.all.includes(:scrape_entries).references(:scrape_entries) : 
          Scrape.where(status: status).includes(:scrape_entries).references(:scrape_entries)
      end
    end

    class Find < Queries::BaseQuery
      argument :search, String, required: true

      type [Types::ScrapeType], null: false

      def resolve(search:)
        Scrape.where("LOWER(name) like '%#{search.downcase}%'").includes(:scrape_entries).references(:scrape_entries)
      end
    end
  end
end