class Validations::LinkValidator < ActiveModel::Validator
	
	def validate(record)
		
		url = record.send(:url)
		units_url = record.send(:units_url)

		record.errors.add :base, "Invalid url"        unless valid_url?(url)
		record.errors.add :base, "Invalid units url"  if units_url != nil && !valid_url?(units_url)
		
		if !url.include?("rentcafe.com") && !url.include?("apartments.com")
			record.errors.add :base, "Invalid url! Allowed domains are apartments.com and rentcafe.com"
		end
	end

	def valid_url?(url)
		return false if url.include?("<script")
		url_regexp = /\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix
		url =~ url_regexp ? true : false
	end
end