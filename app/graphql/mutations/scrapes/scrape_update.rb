module Mutations::Scrapes

   class ScrapeUpdate < Mutations::BaseMutation

      argument :scrape_id, ID, required: true
      argument :name, String, required: false
      # argument :status, Integer, required: false
      argument :frequency, String, required: false
      argument :scheduled_at, String, required: false
      argument :add_link_ids, [Integer], required: false
      argument :remove_scrape_entry_ids, [Integer], required: false

      field :scrape, Types::ScrapeType, null: true
      field :message, String, null: true
      field :scrape_entries_created, Integer, null: true
      field :scrape_entries_deleted, Integer, null: true
      field :errors, [String], null: true

      def resolve(**args)

         scrape = Scrape.find(args[:scrape_id])
         scrape.name = args[:name] if args[:name]
        #  scrape.status = args[:status] if args[:status]
         scrape.scheduled_at = args[:scheduled_at].to_datetime if args[:scheduled_at]  && args[:scheduled_at].to_datetime
         scrape.frequency = args[:frequency] if args[:frequency]
         if scrape.save
            if args[:add_link_ids] && args[:add_link_ids].size > 0
               scrape_entries_created = 0

               args[:add_link_ids].each do |link_id|
                  if Link.kept.find_by(id: link_id) && scrape.scrape_entries.where("link_id = ?", link_id).blank?
                     scrape.scrape_entries << ScrapeEntry.new(link_id: link_id)
                     scrape_entries_created += 1
                  end
               end
            end

            if args[:remove_scrape_entry_ids] && args[:remove_scrape_entry_ids].size > 0
               scrape_entries_deleted = 0

               args[:remove_scrape_entry_ids].each do |scrape_entry_id|
                  unless scrape.scrape_entries.where("id = ?", scrape_entry_id).blank?
                     ScrapeEntry.find_by(id: scrape_entry_id).destroy
                     scrape_entries_deleted += 1
                  end
               end
            end

            {scrape: scrape,
               message: "Scrape updated successfully, #{scrape_entries_created} scrape entries created, #{scrape_entries_deleted} scrape entries deleted",
               scrape_entries_created: scrape_entries_created,
               scrape_entries_deleted: scrape_entries_deleted}
         else
            {message: ["Error while updating the scrape"],
               errors: scrape.errors.full_messages}
         end

      rescue Exception => e
         puts e.message
         puts e.backtrace.join("\n")
         return { message: ["Oops, something went wrong!"], errors: [e.message] }
      end

   end

end