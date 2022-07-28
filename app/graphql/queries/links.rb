module Queries
  module Links
    # class AllLinks < Queries::BaseQuery
    #   argument :city_id, Integer, required: false

    #   type [Types::LinkType], null: false
  
    #   def resolve(city_id:nil)
    #     city_id ? Link.where(city_id: city_id) : Link.all
    #   end
    # end

    class Links < Queries::BaseQuery
      argument :city_id, Integer, required: false
      argument :include_discarded, Boolean, required: false

      type [Types::LinkType], null: false
        
      def resolve(city_id:nil, include_discarded:false)
        if include_discarded
          city_id ? Link.where(city_id: city_id).includes(:city) : Link.all.includes(:city)
        else
          city_id ? Link.kept.where(city_id: city_id).includes(:city) : Link.kept.includes(:city)
        end
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