module Types
  class MutationType < Types::BaseObject

    field :city_create, mutation: Mutations::Cities::CityCreate, description: "New city added successfully", null: false

    field :links_create, mutation: Mutations::Links::LinksCreate, description: "Links added successfully", null: false

    field :scrape_create, mutation: Mutations::Scrapes::ScrapeCreate, description: "Scrape created successfully", null: false
    
    field :scrape_update, mutation: Mutations::Scrapes::ScrapeUpdate, description: "Scrape updated successfully", null: false

  end
end
