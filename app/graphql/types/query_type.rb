module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :summary, resolver: Queries::Summary::Summary, description: "Returns all summary numbers"

    field :algos, resolver: Queries::Algos::Algos, description: "Returns all algorithms"

    field :cities, resolver: Queries::Cities::Cities, description: "Returns all cities"
    field :city, resolver: Queries::Cities::Find, description: "Returns single city searched by name"

    # field :all_links, resolver: Queries::Links::AllLinks, description: "Returns all links or links for given city_id"
    field :links, Types::LinkType.connection_type, connection: true, resolver: Queries::Links::Links, description: "Returns all (except discarded) links or links for given city_id. Pass include_discarded: true to get all links."
    field :link, resolver: Queries::Links::Find, description: "Returns single link searched by URL"

    # field :scrapes, Types::ScrapeType.connection_type, connection: true, resolver: Queries::Scrapes::Scrapes, description: "Returns all scrapes with given status(es)."
    field :scrape, resolver: Queries::Scrapes::Find, description: "Returns scrapes searched by search text"
    field :allScrape, Types::ScrapeType.connection_type, connection: true, resolver: Queries::Scrapes::AllScrapes, description: "Returns all scrapes"

    field :scrapeEntries, resolver: Queries::ScrapeEntries::Find, description: "Returns scrape_entries from on scrape_id"
		
		field :scrape_history, resolver: Queries::ScrapeHistories::Find, description: "Returns scrape history with scrape entry histories"
  end
end
