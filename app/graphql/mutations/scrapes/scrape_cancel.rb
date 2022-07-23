module Mutations::Scrapes

   class ScrapeCancel < Mutations::BaseMutation

      argument :scrapeId, Integer, required: true

      field :message, String, null: true
      field :errors, [String], null: true

      def resolve(scrapeId:)

         scrape = Scrape.find(scrapeId)

         unless scrape.blank?
            
            if scrape.inprogress?

               scrape.cancel

               return {message: "Scrape #{scrape.name} cancelled successfully"}
            else
               return {message: "Scrape #{scrape.name} is not running right now"}
            end

         else
            return {message: "Scrape not found"}
         end

      rescue Exception => e
         puts e.message
         puts e.backtrace.join("\n")
         return { message: "Oops, something went wrong!", errors: [e.message] }
      end



   end

end