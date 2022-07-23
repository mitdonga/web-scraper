module Types
  class MutationType < Types::BaseObject

    field :city_create, mutation: Mutations::Cities::CityCreate, description: "Add new city", null: false

    field :links_create, mutation: Mutations::Links::LinksCreate, description: "Add links to city", null: false

    field :link_discard, mutation: Mutations::Links::LinkDiscard, description: "Discard link", null: false

    field :link_undiscard, mutation: Mutations::Links::LinkUndiscard, description: "Undiscard link", null: false

    field :scrape_create, mutation: Mutations::Scrapes::ScrapeCreate, description: "Create scrape", null: false
    
    field :scrape_update, mutation: Mutations::Scrapes::ScrapeUpdate, description: "Update scrape", null: false

    field :scrape_run, mutation: Mutations::Scrapes::ScrapeRun, description: "Run scrape_entries from Scrape", null: false

    field :scrape_cancel, mutation: Mutations::Scrapes::ScrapeCancel, description: "Cancel running scrape", null: false

  end
end
