module Mutations::Scrapes

   class ScrapeRun < Mutations::BaseMutation

      argument :scrape_id, Integer, required: true

      field :message, String, null: true
      field :errors, [String], null: true

      def resolve(scrape_id: )

         runningScrape = Scrape.find_by(status: "inprogress")

         if runningScrape.blank?

            if !Scrape.find_by(id: scrape_id).blank?

               scrape = Scrape.find(scrape_id)

               Thread.new do
                  execution_context = Rails.application.executor.run!

                  scraper = Scraper::Runner.new(scrape_id)
                  scraper.run
               ensure
                  execution_context.complete! if execution_context
               end

               return {
                  message: "Scrape #{scrape.name} started successfully"
               }
               
            else
               return {
                  message: "Scrape: #{scrape_id} not found"
               }

            end

         else
            return {
               message: "Scrape: #{runningScrape.name} is already running"
            }
         end

      rescue Exception => e
         puts e.message
         puts e.backtrace.join("\n")
         return { message: "Oops, something went wrong!", errors: [e.message] }
      end

   end

end