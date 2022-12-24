module Mutations::Links
   class LinksCreate < Mutations::BaseMutation

      argument :urls, [String], required: true
      argument :city_id, Integer, required: true

      field :links, [Types::LinkType], null: true
      field :message, String, null: true
      field :errors, [String], null: true

      def resolve(urls:, city_id:)

				if city = City.find(city_id) 

					links_created = []
					urls.each do |u|
						url = URI.extract(u, /http(s)?/)[-1]
						if url
							url = url[-1] == "/" ? url : url.insert(-1, "/")
							if Link.where("url LIKE ?", "%#{url}%").blank?
								links_created << Link.create(url: url, city_id: city_id)
							end
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