module Mutations::Links
   class LinkDiscard < Mutations::BaseMutation

      argument :id, Integer, required: true
 
      field :message, String, null: true
      field :errors, [String], null: true

      def resolve(id: )            
            link = Link.find(id)
            if link && link.discard
               return { message: "link #{id} discarded successfully" }
            else
               return { message: "Link not found or already discarded" }
            end
      rescue Exception => e
         puts e.message
         puts e.backtrace.join("\n")
         return { message: "Oops, something went wrong!", errors: [e.message] }
      end
   end
end