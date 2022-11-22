module Mutations::Links
	class ScrapeLink < Mutations::BaseMutation

		 argument :id, Integer, required: true

		 field :message, String, null: true
		 field :errors, [String], null: true

		 def resolve(id: )            
				link = Link.find(id)
				if link
					Thread.new do
						execution_context = Rails.application.executor.run!
						scraper = Scraper::PropertyRunner.new(id)
						scraper.run
					ensure
							execution_context.complete! if execution_context
					end

					runningScrape = Scrape.find_by(status: "inprogress")

					if runningScrape.nil?
						return { message: "Scraping Started For #{link.name}", errors: [] }
					else
						return { message: "Scraping is already running", errors: ["Scrape #{runningScrape.name} is already running, try again later"] }
					end
				else
					return { message: "Link not found", errors: ["Link Not found"] }
				end
		 rescue Exception => e
				puts e.message
				puts e.backtrace.join("\n")
				return { message: "Oops, something went wrong!", errors: [e.message] }
		 end
	end
end