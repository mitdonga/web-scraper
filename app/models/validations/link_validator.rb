class Validations::LinkValidator < ActiveModel::Validator
	
	def validate(record)
		
		url = record.send(:url)
		units_url = record.send(:units_url)

		record.errors.add :base, "Invalid url"        unless valid_url?(url)
		record.errors.add :base, "Invalid units url"  if units_url != nil && !valid_url?(units_url)
		
		unless is_valid_domain(url)
			record.errors.add :base, "Invalid url! This domain is not allowed to scrape"
		end
	end

	def valid_url?(url)
		return false if url.include?("<script")
		url_regexp = /\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix
		url =~ url_regexp ? true : false
	end

	private
	
	def is_valid_domain(url)
		allowed_domains = Rails.application.config.allowed_domains
		allowed_domains.each do |domain|
			return true if url.include? domain
		end
		return false
	end

end