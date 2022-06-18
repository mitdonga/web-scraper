module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :algos, resolver: Queries::Algos::Algos, description: "Returns all algorithms"

    field :cities, resolver: Queries::Cities::Cities, description: "Returns all cities"
    field :city, resolver: Queries::Cities::Find, description: "Returns single city searched by name"

    field :links, resolver: Queries::Links::Links, description: "Returns all links or links for given city_id"
    field :link, resolver: Queries::Links::Find, description: "Returns single link searched by URL"

  end
end
