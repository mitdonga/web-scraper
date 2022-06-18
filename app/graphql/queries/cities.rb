module Queries
  module Cities
    class Cities < Queries::BaseQuery
      type [Types::CityType], null: false
  
      def resolve
        City.all.order(:name)
      end
    end

    class Find < Queries::BaseQuery
      argument :name, String, required: true

      type Types::CityType, null: false

      def resolve(name:)
        City.find_by(name: name)
      end
    end
  end
end