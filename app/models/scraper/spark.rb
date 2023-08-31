require "graphql/client"
require "graphql/client/http"

module Scraper::Spark
  # Configure GraphQL endpoint using the basic HTTP network adapter.
  HTTP = GraphQL::Client::HTTP.new("https://api.sparkapt.com") do
  # HTTP = GraphQL::Client::HTTP.new("https://sparkgql.compli.tech/") do
  # HTTP = GraphQL::Client::HTTP.new("http://localhost:3002") do
    def headers(context)
      # Optionally set any HTTP headers
      {
        "User-Agent": "Spark Scraper",
        # "Authorization": "Bearer uKlZL56BlpSFfDcBt8Qx0rj1qtA=--dvCdpMBynTRdSy9w--z8sg1hGRO18Q8T5X/60cDw=="
        # "Authorization": "Bearer 1REgnp7QJ8RQaYbWHjjF43s0ypQ=--BQoNVlFqDspfOFoq--8cqrb+mpn+JWaFuYNCgs3Q==",
        # "Authorization": "Bearer UzhRvizjVCCBtt49V3KKgeZTmNg=--MkhL1VCdnciUSqxv--tB5/ieezgJbABV67XaA4aQ==",
				"SPARK-API-KEY": "NZ2Urwsi4w5U7xGJ48WXPcP8z4d4fMvQIRC3mEcI15nKF3xs0tVTibrCfHsHgoNooc8Ua0caY1hgI5Fq" # Live
				# "SPARK-API-KEY": "m1gcIjTrNfFpmsBW2Y6FWtKUPS5kQDf6A1xBB28DBXGzDaEoOIKHAoKx9YqTdjydKtPtZ9fgn1ALq4WV" # Demo
				# "SPARK-API-KEY": "nnWz0Be1MQb14cc3IITxTtP83R52M5CQI2qpcn171Vig3a1TZzkdjyZnVu1gRMwrqkbT6Dak9AiB2dho"  # Local
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

  # cityCreate = <<-'GRAPHQL'
  #   mutation (
  #     $name: ValidString!,
  #     $stateName: ValidString!,
  #     $timeZone: ValidString!,
  #     $isVisible: Boolean!
  #   ) {
  #     cityCreate(
  #       input: { name: $name, stateName: $stateName, timeZone: $timeZone, isVisible: $isVisible }
  #     ) {
  #       city {
  #         id
  #         name
  #       }
  #       errors
  #       message
  #     }
  #   }
  # GRAPHQL
  # Kernel.const_defined?(:CreateCity) || Kernel.const_set(:CreateCity, Scraper::Spark::Client.parse(cityCreate))

  propertiesWithoutJoinData = <<-'GRAPHQL'
    query ($cityId: Int, $search: ValidString) {
      propertiesWithoutJoinData(cityId:$cityId, search:$search, orderBy: [{id:"id"}], onlyAvailable:false, exactMatch: true) {
        totalCount
        edges {
          node {
            id
            floorPlans {
              id
              name
							sqft
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
        $name: ValidString!,
        $neighborhood: ValidString!,
        $zip: ValidString,
        $cityId: Int!,
        $address: ValidString
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
        $resetFloorplan: Boolean
    ) {
      unitMultiUpdateAvailability(input: {propertyId: $propertyId, resetFloorplan: $resetFloorplan}) {
        message
        errors
      }
    }
  GRAPHQL
  Kernel.const_defined?(:PropertyUnitsReset) || Kernel.const_set(:PropertyUnitsReset, Scraper::Spark::Client.parse(propertyUnitsReset))

  updateFloorPlansSizeRentAvailability = <<-'GRAPHQL'
		mutation (
				$propertyId: Int!, 
				$forAvailableUnitsOnly: Boolean
			) {
			updateFloorPlansSizeRentAvailability(
				input: { 
					propertyId: $propertyId, 
					forAvailableUnitsOnly: $forAvailableUnitsOnly,
					autoUpdate: true
				}) {
				clientMutationId
				errors
				message
				property {
					floorPlans{
						id
						name
						availableFrom
						availableTo
						sqftMax
						sqftMin
						sqft
						isAvailable
					}
					id
					name 
				}
			}
		}
  GRAPHQL
  Kernel.const_defined?(:UpdateFloorPlansSizeRentAvailability) || Kernel.const_set(:UpdateFloorPlansSizeRentAvailability, Scraper::Spark::Client.parse(updateFloorPlansSizeRentAvailability))

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