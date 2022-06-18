module Queries
  module Links
    class Links < Queries::BaseQuery
      argument :city_id, Integer, required: false

      type [Types::LinkType], null: false
  
      def resolve(city_id:nil)
        city_id ? Link.where(city_id: city_id) : Link.all
      end
    end

    class Find < Queries::BaseQuery
      argument :url, String, required: true

      type Types::LinkType, null: false

      def resolve(url:)
        Link.find_by(url: url)
      end
    end
  end
end