module Scraper::SaverMethods
  def process_item(property, options: {})
    # Here you can save item to the database, send it to a remote API or
    # simply save item to a file format using `save_to` helper:

    # To get the name of current spider: `spider.class.name`
    # save_to "db/#{spider.class.name}.json", item, format: :json
    # puts "[SAVER] Processing #{property}"

    # Save property to SPARK backend if floor_plans are available
    if property[:floorPlans].size > 0
      # property[:cityId] = city_id(property[:city], property[:state])
      property_from_spark = find_or_create_property(property)
      property[:id] = property_from_spark["id"].to_i
     
      # Reset existing property units' availability to unavailable
      reset_units_availability(property[:id])

      # find and/or create floor plans for the property
      new_floor_plans = []
      new_units = []

      updated_floor_plans = []
      updated_units = []

      property[:floorPlans].each do |fp|
        fp[:propertyId] = property[:id]
        floor_plan_from_spark = find_floor_plan(fp, property_from_spark["floorPlans"])

        if floor_plan_from_spark
          fp[:id] = floor_plan_from_spark["id"].to_i

          # find or create units for this floor plan
          fp[:units].each do |u|
            u[:propertyId] = property[:id]
            u[:floorPlanId] = fp[:id]
            # if u[:id].blank?
            unit_from_spark = find_unit(u, property_from_spark["typeDetails"])
            # end
            if unit_from_spark
              u[:id] = unit_from_spark["id"].to_i
              updated_units << u
            else
              new_units << u #.except(:)
            end
          end
          updated_floor_plans << fp.except(:units)
        else
          new_floor_plans << fp.except(:units)
        end
      end

      if updated_floor_plans.size > 0
        # Update floor plans
        update_floor_plans(updated_floor_plans)
      end

      if updated_units.size > 0
        # Update unit pricing / availability information
        update_units(updated_units)
      end

      # Save the new floor plans
      if new_floor_plans.size > 0
        floor_plans_from_spark = create_floor_plans(new_floor_plans)
        # TODO: Create units for newly created floor plans
        property[:floorPlans].each do |fp|
          if fp[:id].blank?
            floor_plan_from_spark = find_floor_plan(fp, floor_plans_from_spark)
            if floor_plan_from_spark
              fp[:id] = floor_plan_from_spark["id"].to_i
              fp[:units].each do |u|
                u[:propertyId] = property[:id].to_i
                u[:floorPlanId] = fp[:id].to_i
                new_units << u #.except(:)
              end
            end
          end
        end
        # # floor_plans_from_spark.each do |fp|
        # end
      end

      # Save the new units
      if new_units.size > 0
        units_from_spark = create_units(new_units)
        property[:floorPlans].each do |fp|
          fp[:units].each do |u|
            if u[:id].blank?
              unit_from_spark = find_unit(u, units_from_spark)
              # byebug if !unit_from_spark
              u[:id] = unit_from_spark["id"].to_i
            end
          end
        end
      end

      puts "[INFO] Saved - #{property[:name].upcase}"
      # save_to "saved.json", property, format: :pretty_json
    else
      puts "[INFO] Skipped - #{property[:name].upcase}"
      # save_to "skipped.json", property, format: :pretty_json
    end

    property
  end


  # def city_id(city_name, state_name=nil)
  #   @cities.each do |city|
  #     if city_name.downcase == city["name"].downcase
  #       return city["id"].to_i
  #     end
  #   end
  #   return state_name ? create_city(city_name, state_name)["id"].to_i : nil
  # end

  def find_floor_plan(floor_plan, floor_plans)
    # find floor_plan from the spark property
    if floor_plans
      floor_plans.each do |fp|
        if fp["name"].downcase == floor_plan[:name].downcase && fp["sqft"] == floor_plan[:sqft]
          return fp
        end
      end
    end
    return nil 
  end

  def find_unit(unit, units)
    # check if it exists in spark property
    if units
      units.each do |u|
        if u["aptNo"].to_s.downcase == unit[:aptNo].downcase
          return u
        end
      end
    end
    return nil 
  end

  def find_or_create_property(property)
    result = Scraper::Spark::Client.query(FindProperty, variables: {cityId: property[:cityId], search: property[:name]})

    if result.original_hash["data"]["propertiesWithoutJoinData"] && 
      result.original_hash["data"]["propertiesWithoutJoinData"]["edges"].size > 0
      puts "[INFO] Property found - #{property[:name].upcase}"
      return result.original_hash["data"]["propertiesWithoutJoinData"]["edges"][0]["node"]
    else
      # create property and return
      return create_property(property)
    end
  end

  def self.sign_in
    mutation = <<-'GRAPHQL'
      mutation ($email: ValidString!, $password: ValidString!) {
        signin(input: { email: $email, password: $password }) {
          user {
            name
            isAdmin
            isVa
            approved
            status
            subscriptions {
              isTrial
              currentEndDatetime
              currentStartDatetime
              active
              status
            }
          }
          authenticationToken
          message
          errors
        }
      }
    GRAPHQL
    Kernel.const_set(:SignIn, Scraper::Spark::Client.parse(mutation))

    result = Scraper::Spark::Client.query(SignIn, variables: {email: "ashwin@complitech.net", password: "12345678"})

    # puts result.data
    puts result.original_hash["data"]
  end

  # def create_city(city_name, state_name, is_visible=false, timeZone="Central Time (US & Canada)")
  #   result = Scraper::Spark::Client.query(CreateCity, variables: {name: city_name, stateName: state_name, isVisible: is_visible, timeZone: timeZone})

  #   if result.original_hash["data"]["cityCreate"]["errors"] &&
  #     result.original_hash["data"]["cityCreate"]["errors"].size > 0 
  #     puts "[ERROR] City was not created - #{city_name}"
  #   else
  #     puts "[INFO] City created successfully - #{city_name}"
  #     @cities = all_cities
  #     return result.original_hash["data"]["cityCreate"]["city"]
  #   end
  #   return nil
  # end

  def create_floor_plans(floor_plans)
    result = Scraper::Spark::Client.query(FloorPlanMultiCreate, variables: {createFloorPlans: floor_plans})

    if result.original_hash["data"]["floorPlanMultiCreate"]["errors"] &&
      result.original_hash["data"]["floorPlanMultiCreate"]["errors"].size > 0 
      puts "[ERROR] Floor plans were not created"
    else
      puts "[INFO] Floor plans created successfully - #{result.original_hash["data"]["floorPlanMultiCreate"]["floorPlans"].size} floor plans"
      return result.original_hash["data"]["floorPlanMultiCreate"]["floorPlans"]
    end
    return nil
  end

  def update_floor_plans(floor_plans)
    result = Scraper::Spark::Client.query(FloorPlanMultiUpdate, variables: {updateFloorPlans: floor_plans})

    if result.original_hash["data"]["floorPlanMultiUpdate"]["errors"] && 
      result.original_hash["data"]["floorPlanMultiUpdate"]["errors"].size > 0 
      puts "[ERROR] Floor plans were not updated"
    else
      puts "[INFO] Floor plans updated successfully - #{result.original_hash["data"]["floorPlanMultiUpdate"]["floorPlans"].size} floor plans"
      return result.original_hash["data"]["floorPlanMultiUpdate"]["floorPlans"]
    end
    return nil
  end

  def create_units(units)
    result = Scraper::Spark::Client.query(UnitMultiCreate, variables: {createUnits: units})

    if result.original_hash["data"]["unitMultiCreate"] &&
      result.original_hash["data"]["unitMultiCreate"]["errors"] &&
      result.original_hash["data"]["unitMultiCreate"]["errors"].size > 0 
      puts "[ERROR] Units were not created"
    else
      puts "[INFO] Units created successfully - #{result.original_hash["data"]["unitMultiCreate"]["units"].size} units"
      return result.original_hash["data"]["unitMultiCreate"]["units"]
    end
    return nil
  end

  def reset_units_availability(property_id)
    result = Scraper::Spark::Client.query(PropertyUnitsReset, variables: {propertyId: property_id.to_i})
    if result.original_hash["data"]["unitMultiUpdateAvailability"]["errors"] &&
      result.original_hash["data"]["unitMultiUpdateAvailability"]["errors"].size > 0 
      puts "[ERROR] Units availability was not reset"
      return false
    else
      puts "[INFO] Units availability updated successfully"
      return true
    end
    return nil
  end

  def update_units(units)
    result = Scraper::Spark::Client.query(UnitMultiUpdate, variables: {updateUnits: units})
    if result.original_hash["data"]["unitMultiUpdate"]["errors"] &&
      result.original_hash["data"]["unitMultiUpdate"]["errors"].size > 0 
      puts "[ERROR] Units were not updated"
    else
      puts "[INFO] Units updated successfully - #{result.original_hash["data"]["unitMultiUpdate"]["units"].size} units"
      return result.original_hash["data"]["unitMultiUpdate"]["units"]
    end
    return nil
  end

  def create_property(property)
    result = Scraper::Spark::Client.query(CreateProperty, variables: {name: property[:name], neighborhood: property[:neighborhood], zip: property[:zip], cityId: property[:cityId], address: property[:address]})

    if result.original_hash["data"]["propertyCreate"]["errors"] &&
      result.original_hash["data"]["propertyCreate"]["errors"].size > 0 
      puts "[ERROR] Property was not created - #{property[:name].upcase}"
    else
      puts "[INFO] Property created successfully - #{property[:name].upcase}"
      return result.original_hash["data"]["propertyCreate"]["property"]
    end
    # byebug
    return nil
  end

	def all_cities
    result = Scraper::Spark::Client.query(AllCities)

    puts "[INFO] All cities fetched successfully."
    return result.original_hash["data"]["allCities"]
  end

end