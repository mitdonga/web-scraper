module Queries
  module Algos
    class Algos < Queries::BaseQuery
      type [Types::AlgoType], null: false
  
      def resolve
        Algo.all
      end
    end

  end
end