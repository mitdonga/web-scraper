module Scraper::Utils
  def parse_date(date_string)
    return nil if date_string.to_s.strip.downcase == "soon" or date_string.to_s.strip.downcase == "not available" or date_string.to_s.strip.downcase == "unavailable"
    date_string.to_s.strip.downcase == "now" ? DateTime.now.to_date : (date_string.to_s.to_date < DateTime.now.to_date ? date_string.to_s.to_date + 1.year : date_string.to_s.to_date)
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
        when "3 beds"
          "bedroom3"
        when "4 beds"
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
end