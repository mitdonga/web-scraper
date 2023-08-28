module Mutations::Links
   class LinksCreate < Mutations::BaseMutation

      argument :urls, [String], required: false
			argument :excel_file, Types::FileType, required: false
      argument :city_id, Integer, required: true

      field :links, [Types::LinkType], null: true
      field :message, String, null: true
      field :errors, [String], null: true

      def resolve(urls: [], city_id:, excel_file: nil)

				city = City.find(city_id)
				return { message: "City not found Or Invalid input", errors: ["City not found Or Invalid input"] } if city.nil?

				added_links_count = 0
				links_created = []

				if urls.any?
					urls.each do |u|
						url = URI.extract(u, /http(s)?/)[-1]
						if url
							url = valid_url(url)
							if Link.where("url LIKE ?", "%#{url}%").blank?
								links_created << Link.create(url: url, city_id: city_id)
							end
						end
					end
					added_links_count = links_created.size
				end

				if excel_file
					data = Roo::Spreadsheet.open(excel_file) # open spreadsheet
					headers = data.row(1) # get header row
	
					data.each_with_index do |row, idx|
						
						next if idx == 0 # skip header
						link_data = Hash[[headers, row].transpose]

						url = valid_url(link_data['URLs'])
						if Link.where("url LIKE ?", "%#{url}%").blank?
							units_url = valid_url(link_data['UNITS URLs'])
							link = Link.new(city: city, url: url, units_url: units_url)
							
							if link.save
								links_created << link 
								added_links_count += 1
							end
						end
					end 
				end

				return { links: links_created, message: "#{added_links_count} links created successfully" }
      rescue Exception => e
         puts e.message
         puts e.backtrace.join("\n")
         return { message: "Oops, something went wrong!", errors: [e.message] }
      end

			def valid_url(url)
				return nil if url.nil?
				url[-1] == "/" ? url : url.insert(-1, "/")
			end

   end
end