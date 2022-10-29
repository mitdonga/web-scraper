require "graphql/client"
require "graphql/client/http"

module Scraper::Spark
  # Configure GraphQL endpoint using the basic HTTP network adapter.
  # HTTP = GraphQL::Client::HTTP.new("https://sparkgql.compli.tech") do
  HTTP = GraphQL::Client::HTTP.new("https://api.sparkapt.com") do
    def headers(context)
      # Optionally set any HTTP headers
      {
        "User-Agent": "Spark Scraper",
        "Authorization": "Bearer uKlZL56BlpSFfDcBt8Qx0rj1qtA=--dvCdpMBynTRdSy9w--z8sg1hGRO18Q8T5X/60cDw=="
        # "Authorization": "Bearer lXohS2op8KEhcW7RSvICwTCAeeQ=--wFzME/wPVPgK5W5a--yn8FsFAR67MbNkxoR+FzKA=="
        # "Authorization": "Bearer ruq6bdyoBcCLEfNNY+3VK0S/7ks=--wUMtL4DE5npnFeoI--uAB5s6RxJc59gZgSZxLoaQ=="
      }
    end
  end  
  # Fetch latest schema on init, this will make a network request
  Schema = GraphQL::Client.load_schema(HTTP)

  # However, it's smart to dump this to a JSON file and load from disk
  #
  # Run it from a script or rake task
  #   GraphQL::Client.dump_schema(SPARK::HTTP, "path/to/schema.json")
  #
  # Schema = GraphQL::Client.load_schema("path/to/schema.json")

  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)

  floorPlanMultiUpdate = <<-'GRAPHQL'
    mutation ($updateFloorPlans: [FloorPlanUpdate!]!) {
      floorPlanMultiUpdate(input: { updateFloorPlans: $updateFloorPlans }) {
        floorPlans {
          id
          name
          bed
          bath
          price
          sqft
        }
        message
        errors
      }
    }
  GRAPHQL
  Kernel.const_defined?(:FloorPlanMultiUpdate) || Kernel.const_set(:FloorPlanMultiUpdate, Scraper::Spark::Client.parse(floorPlanMultiUpdate))

  unitMultiUpdate = <<-'GRAPHQL'
    mutation ($updateUnits: [UnitUpdate!]!) {
      unitMultiUpdate(input: { updateUnits: $updateUnits }) {
        units {
          id
          floorPlan {
            id
          }
          moveIn
          aptNo
          price
          size
          isAvailable
        }
        message
        errors
      }
    }
  GRAPHQL
  Kernel.const_defined?(:UnitMultiUpdate) || Kernel.const_set(:UnitMultiUpdate, Scraper::Spark::Client.parse(unitMultiUpdate))

  unitMultiCreate = <<-'GRAPHQL'
    mutation ($createUnits: [UnitCreate!]!) {
      unitMultiCreate(input: { createUnits: $createUnits }) {
        units {
          id
          floorPlan {
            id
          }
          moveIn
          aptNo
          price
          size
          isAvailable
        }
        message
        errors
      }
    }
  GRAPHQL
  Kernel.const_defined?(:UnitMultiCreate) || Kernel.const_set(:UnitMultiCreate, Scraper::Spark::Client.parse(unitMultiCreate))

  floorPlanMultiCreate = <<-'GRAPHQL'
    mutation ($createFloorPlans: [FloorPlanCreate!]!) {
      floorPlanMultiCreate(input: { createFloorPlans: $createFloorPlans }) {
        floorPlans {
          id
          name
          bed
          bath
          price
          sqft
        }
        message
        errors
      }
    }
  GRAPHQL
  Kernel.const_defined?(:FloorPlanMultiCreate) || Kernel.const_set(:FloorPlanMultiCreate, Scraper::Spark::Client.parse(floorPlanMultiCreate))

  cityCreate = <<-'GRAPHQL'
    mutation (
      $name: String!,
      $stateName: String!,
      $isVisible: Boolean!
    ) {
      cityCreate(
        input: { name: $name, stateName: $stateName, isVisible: $isVisible }
      ) {
        city {
          id
          name
        }
        errors
        message
      }
    }
  GRAPHQL
  Kernel.const_defined?(:CreateCity) || Kernel.const_set(:CreateCity, Scraper::Spark::Client.parse(cityCreate))

  propertiesWithoutJoinData = <<-'GRAPHQL'
    query ($cityId: Int, $search: String) {
      propertiesWithoutJoinData(cityId:$cityId, search:$search, orderBy: [{id:"id"}], onlyAvailable:false) {
        totalCount
        edges {
          node {
            id
            floorPlans {
              id
              name
            }
            typeDetails {
              id
              floorPlan {
                id
                name
              }
              size
              aptNo
            }
          }
        }
      }
    }
  GRAPHQL
  Kernel.const_defined?(:FindProperty) || Kernel.const_set(:FindProperty, Scraper::Spark::Client.parse(propertiesWithoutJoinData))

  propertyCreate = <<-'GRAPHQL'
    mutation (
        $name: String!,
        $neighborhood: String!,
        $zip: String,
        $cityId: Int!,
        $address: String
      ) {
        propertyCreate(
          input: {
            name: $name
            isConfirmed: false
            neighborhood: $neighborhood
            zip: $zip
            cityId: $cityId
            address: $address
          }
        ) {
          property {
            id
          }
          message
          errors
        }
      }
  GRAPHQL
  Kernel.const_defined?(:CreateProperty) || Kernel.const_set(:CreateProperty, Scraper::Spark::Client.parse(propertyCreate))

  propertyUnitsReset = <<-'GRAPHQL'
    mutation (
        $propertyId: Int!
    ) {
      unitMultiUpdateAvailability(input: {propertyId: $propertyId}) {
        message
        errors
      }
    }
  GRAPHQL
  Kernel.const_defined?(:PropertyUnitsReset) || Kernel.const_set(:PropertyUnitsReset, Scraper::Spark::Client.parse(propertyUnitsReset))

  allCities = <<-'GRAPHQL'
    query {
      allCities {
        id
        name
      }
    }
  GRAPHQL
  Kernel.const_defined?(:AllCities) || Kernel.const_set(:AllCities, Scraper::Spark::Client.parse(allCities))

end