module Mutations::Cities
   class CityCreate < Mutations::BaseMutation

      argument :name, String, required: true
      argument :s_id, Integer, required: true

      field :city, Types::CityType, null: true
      field :message, String, null: true
      field :errors, [String], null: true

      def resolve(name:, s_id:)

         if City.where(s_id: s_id).blank? && City.where(name: name).blank?
            city = City.new(name: name, s_id: s_id)
            if city.save
               {city: city,
               message: "City created successfully"}
            else
               {message: "City not created",
               errors: city.errors.full_messages}
            end

         else
            {message: "Spark_id or City already exists, Please input unique entry"}
         end
      rescue Exception => e
         puts e.message
         puts e.backtrace.join("\n")
         return { message: "Oops, something went wrong!", errors: [e.message] }
      end
   end
end