module Mutations::Links
	class UpdateFpimgFetching < Mutations::BaseMutation
		argument :id, Integer, required: true
		argument :fetch_floorplan_images, Boolean, required: true
 
		field :message, String, null: true
		field :errors, [String], null: true

		def resolve(id:, fetch_floorplan_images: )
			 link = Link.find(id)
			 if link
					link.update(fetch_floorplan_images: fetch_floorplan_images)
					return { message: "link #{id} updated successfully" }
			 else
					return { message: "link not found" }
			 end
		rescue Exception => e
			 puts e.message
			 puts e.backtrace.join("\n")
			 return { message: "Oops, something went wrong!", errors: [e.message] }
		end
	end
end