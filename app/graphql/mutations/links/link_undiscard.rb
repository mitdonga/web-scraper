module Mutations::Links
   class LinkUndiscard < Mutations::BaseMutation

      argument :id, Integer, required: true
 
      field :message, String, null: true
      field :errors, [String], null: true

      def resolve(id: )
         link = Link.find(id)
         if link && link.undiscard
            return { message: "link #{id} undiscarded successfully" }
         else
            return { message: "link not found or already undiscarded" }
         end
      rescue Exception => e
         puts e.message
         puts e.backtrace.join("\n")
         return { message: "Oops, something went wrong!", errors: [e.message] }
      end
   end
end