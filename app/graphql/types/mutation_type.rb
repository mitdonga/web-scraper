module Types
  class MutationType < Types::BaseObject

    field :city_create, mutation: Mutations::Cities::CityCreate, description: "Add new city", null: false

    field :links_create, mutation: Mutations::Links::LinksCreate, description: "Add links to city", null: false

    field :link_discard, mutation: Mutations::Links::LinkDiscard, description: "Discard link", null: false
		
    field :scrape_link, mutation: Mutations::Links::ScrapeLink, description: "Scrape Property From Url", null: false
    
		field :update_fpimg_fetching, mutation: Mutations::Links::UpdateFpimgFetching, description: "Update Floor Plan Fetching", null: false

    field :link_undiscard, mutation: Mutations::Links::LinkUndiscard, description: "Undiscard link", null: false

    field :scrape_create, mutation: Mutations::Scrapes::ScrapeCreate, description: "Create scrape", null: false
    
    field :scrape_update, mutation: Mutations::Scrapes::ScrapeUpdate, description: "Update scrape", null: false

    field :edit_scrape_links, mutation: Mutations::Scrapes::EditLinks, description: "Add & remove scrape entries (links) from scrape", null: false

    field :scrape_run, mutation: Mutations::Scrapes::ScrapeRun, description: "Run scrape_entries from Scrape", null: false

    field :scrape_cancel, mutation: Mutations::Scrapes::ScrapeCancel, description: "Cancel running scrape", null: false
		
    field :scrape_discard, mutation: Mutations::Scrapes::ScrapeDiscard, description: "Discard or undiscard scrape", null: false

    field :delete_scrape_entry, mutation: Mutations::ScrapeEntries::DeleteScrapeEntry, description: "Delete scrape entry", null: false

  end
end
