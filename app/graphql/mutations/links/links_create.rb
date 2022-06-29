module Mutations::Links
   class LinksCreate < Mutations::BaseMutation

      argument :urls, [String], required: true
      argument :city_id, Integer, required: true
      argument :algo_id, Integer, required: true

      field :links, [Types::LinkType], null: true
      field :message, String, null: true
      field :errors, [String], null: true

      def resolve(urls:, city_id:, algo_id:)

         if City.find(city_id) && Algo.find(algo_id)

            links_created = []

            urls.each do |url|

               if Link.find_by(url: url).blank?
                  links_created << Link.create(url: url, city_id: city_id, algo_id: algo_id)
               end
            end

            return { links: links_created, message: "#{links_created.size} links created successfully" }

         else 
            {message: "City or Algo not found"}
         end

      rescue Exception => e
         puts e.message
         puts e.backtrace.join("\n")
         return { message: "Oops, something went wrong!", errors: [e.message] }
      end
   end
end