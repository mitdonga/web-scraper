module Types
  class BaseConnection < Types::BaseObject
    # add `nodes` and `pageInfo` fields, as well as `edge_type(...)` and `node_nullable(...)` overrides
    include GraphQL::Types::Relay::ConnectionBehaviors

    field :total_count, Integer, null: false

    def total_count
      object.items.size  # returns total count in database
      #  object.nodes.size  # returns total count in current returned page
    end
  end
end
