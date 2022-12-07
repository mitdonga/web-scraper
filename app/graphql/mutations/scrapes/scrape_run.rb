module Mutations::Scrapes

   class ScrapeRun < Mutations::BaseMutation

      argument :scrape_id, Integer, required: true
      argument :run_mode, String, required: false

      field :message, String, null: false
      field :scrape, Types::ScrapeType, null: false
      field :errors, [String], null: false

      def resolve(scrape_id:, run_mode:"run")

         runningScrape = ScrapeHistory.find_by(status: "inprogress")

         if runningScrape.blank?

            if Scrape.find_by(id: scrape_id, discard: false)

               scrape = Scrape.find(scrape_id)

               Thread.new do
                  execution_context = Rails.application.executor.run!

                  run_mode == 'resume' ? scraper = Scraper::Runner.new(scrape_id) : scraper = Scraper::Runner.new(scrape_id, 'resume') 
                  
                  scraper.run
               ensure
                  execution_context.complete! if execution_context
               end

               return {
                  message: "Scrape #{scrape.name} started successfully",
									scrape: scrape,
									errors: []
               }
            else
               return {
                  message: "Scrape: #{scrape_id} not found Or It is discarded",
									errors: ["Scrape: #{scrape_id} not found Or It is discarded"]
               }
            end

         else
            return {
               message: "Scrape: #{runningScrape.scrape.name} is already running",
							 errors: ["Scrape: #{runningScrape.scrape.name} is already running"]
            }
         end

      rescue Exception => e
         puts e.message
         puts e.backtrace.join("\n")
         return { message: "Oops, something went wrong!", errors: [e.message] }
      end

   end

end