module Mutations::Links
   class LinkUndiscard < Mutations::BaseMutation

      argument :id, Integer, required: true
 
      field :message, String, null: true
      field :errors, [String], null: true

      def resolve(id: )

         if Link.find(id)
            
            link = Link.find(id)

            if link.undiscard
               return { message: "link undiscarded successfully" }
            else
               return { message: "link is already kept successfully" }
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