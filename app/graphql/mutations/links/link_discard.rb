module Mutations::Links
   class LinkDiscard < Mutations::BaseMutation

      argument :id, Integer, required: true
      # argument :city_id, Integer, required: true
      # argument :algo_id, Integer, required: true

      # field :links, [Types::LinkType], null: true
      field :message, String, null: true
      field :errors, [String], null: true

      def resolve(id: )

         if Link.find(id)
            
            link = Link.find(id)
            if link.discard
               return { message: "link discarded successfully" }
            else
               return { message: "link is already discarded successfully" }
            end

         else 
            {message: "Link not found"}
         end

      rescue Exception => e
         puts e.message
         puts e.backtrace.join("\n")
         return { message: "Oops, something went wrong!", errors: [e.message] }
      end
   end
end