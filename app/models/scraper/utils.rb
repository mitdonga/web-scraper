module Scraper::Utils
  def parse_date(date_string)
		begin
    	return nil if date_string.to_s.strip.downcase == "soon" or date_string.to_s.strip.downcase == "not available" or date_string.to_s.strip.downcase == "unavailable"
    	return nil if date_string.to_s.strip.downcase.include? "soon" or date_string.to_s.strip.include?  "not available" or date_string.to_s.strip.downcase.include? "unavailable"
    	return DateTime.now.to_date if date_string.to_s.strip == "" or date_string.to_s.strip.downcase == "available now"
    	date_string.to_s.strip.downcase == "now" ? DateTime.now.to_date : (date_string.to_s.to_date < DateTime.now.to_date ? date_string.to_s.to_date + 1.year : date_string.to_s.to_date)
		rescue Exception => e
			return DateTime.now.to_date
		end
  end

  def parse_size(size_string)
    size_string ? size_string.gsub(/sq ft|,|\s/, "").to_i : size_string
  end

  def parse_amount(amount_string)
    amount_string && amount_string.length > 0 ? amount_string.gsub(/\$|,|\s/, "").to_i : nil
  end

  def parse_bed(bed_string)
    if bed_string && bed_string.length > 0
      case bed_string.downcase
        when "studio"
          "studio"
        when "convertible"
          "convertible"
        when "1 bed"
          "bedroom1"
        when "2 beds"
          "bedroom2"
        when "2 bed"
          "bedroom2"
        when "3 beds"
          "bedroom3"
        when "3 bed"
          "bedroom3"
        when "4 beds"
          "bedroom4"
        when "4 bed"
          "bedroom4"
      end
    else 
      nil
    end
  end

  def parse_bath(bath_string)
    bath_string && bath_string.length > 0 ? bath_string.gsub(/bath|baths|,|\s/, "").to_f : nil
  end

  def parse_aptno(aptno_string)
    aptno_string && aptno_string.length > 0 ? aptno_string.gsub(/Unit|,|\s/, "") : nil
  end

	def parse_rent(rent_string)
		if rent_string.include? "-"
			arr = rent_string.split("-")
			return {rentMin: arr[0].gsub(/\D/, "").to_i, rentMax: arr[1].gsub(/\D/, "").to_i}
		elsif rent_string.downcase.include? "call"
			return {rentMin: nil, rentMax: nil}
		else
			return {rentMin: rent_string.gsub(/\D/, "").to_i, rentMax: rent_string.gsub(/\D/, "").to_i}
		end
	end

	def parse_movein(movein_string)
		if movein_string
			date = nil
			date = movein_string.split("MoveInDate=")[1]
			# date = movein_string.match(/MoveInDate=[0-1]?[0-9]\/[0-3]?[0-9]\/(?:[0-9]{2})?[0-9]{2}/)&.to_a[0]&.match(/[0-1]?[0-9]\/[0-3]?[0-9]\/(?:[0-9]{2})?[0-9]{2}/)&.to_a[0]
			return Date.strptime(date, "%m/%d/%Y") if date
			Date.today
		else
			Date.today
		end
	end

	def only_numbers(str)
		str&.gsub(/\D/, "")
	end

	def image_url_from_style(str)
		str ? str.match(/url\("([^"]+)"\)/)[1] : nil
	end

	def prase_date_mddyyyy(date_string)
		begin
    	return nil if date_string.to_s.strip.downcase == "soon" or date_string.to_s.strip.downcase == "not available" or date_string.to_s.strip.downcase == "unavailable"
    	return nil if date_string.to_s.strip.downcase.include? "soon" or date_string.to_s.strip.include?  "not available" or date_string.to_s.strip.downcase.include? "unavailable"
    	return DateTime.now.to_date if date_string.to_s.strip == "" or date_string.to_s.strip.downcase.include?("available") or date_string.to_s.strip.downcase.include?("now")
    	Date.strptime(date_string, '%m/%d/%Y')
		rescue Exception => e
			return DateTime.now.to_date
		end
	end

end