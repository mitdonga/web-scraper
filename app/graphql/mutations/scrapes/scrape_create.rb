module Mutations::Scrapes

   class ScrapeCreate < Mutations::BaseMutation

      argument :name, String, required: true
      argument :link_ids, [Integer], required: true
      argument :scheduled_at, String, required: false

      field :scrape, Types::ScrapeType, null: true
      field :message, String, null: true
      field :errors, [String], null: true

      def resolve(name:, link_ids:, scheduled_at: Time.now)

         if Scrape.find_by(name: name).blank?
            scrape = Scrape.new(name: name, scheduled_at: scheduled_at.to_datetime)
            if scrape.save

               link_ids.each do |link_id|

                  if Link.kept.find(link_id)
                     scrape.scrape_entries << ScrapeEntry.new(link_id: link_id)
                  end
               end

               {scrape: scrape,
                message: "New scrape created successfully"}
            else
               {message: "Error while creating scrape",
                  errors: scrape.errors.full_messages}
            end

         else
            {message: "Duplicate scrape name, please enter a different one"}
         end

      rescue Exception => e
         puts e.message
         puts e.backtrace.join("\n")
         return { message: "Oops, something went wrong!", errors: [e.message] }
      end



   end

end