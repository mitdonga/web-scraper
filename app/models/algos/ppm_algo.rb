module Algos::PpmAlgo
	
	# In Progress 
	def parse(response, url:, data: {})

		property = {}

		property[:name] = response.css("h1","entry-title").text.strip
		property[:neighborhood] = response.xpath("//header[@class='entry-header']/h5").text.strip

		property[:floorPlans] = []

		# Address
		property[:address] = response.xpath("//div[@class='col-md-6']/p").text.strip.gsub("\n", ", ") 

		property[:state] = response.xpath("//div[@class='col-md-6']/p").text.strip.split("\n")[1].strip.split(" ")[1]

		property[:zip] = response.xpath("//div[@class='col-md-6']/p").text.strip.split("\n")[1].strip.split(" ")[2].to_i
		floor_plans_url = response.xpath("//div[@class='rm-listings-container']/script").to_a[0].to_a[0][1].to_s
		
		request_to :parse_floor_plans, url: floor_plans_url, data: property

	end

	def parse_floor_plans(response, url:, data: {})
		response.xpath("//div[@class='\\\"unit\\\"']").each do |fp| 
			floor_plans = {}
			floor_plans[:name] = fp.xpath(".//div[@class='\\\"spec'][@spec-sm='']")[0].to_s.split("</span>")[1].gsub(/[^0-9]/, '')

			floor_plans[:moveIn_script] = fp.xpath(".//div[@class='\\\"spec\\\"']/script")[0].children[0].text

			floor_plans[:unit_type_script] = fp.xpath(".//div[@class='\\\"spec\\\"'][2]/script")[0].children[0].text #(Unit type rendering JS Script in string)
			floor_plans[:floor_plan_img_script] = fp.xpath(".//div[@class='\\\"spec\\\"'][3]/script")[0].text #(Unit type rendering JS Script in string)
			floor_plans[:features_script] = fp.xpath(".//div[@class='\\\"spec'][@spec-feature='']/script")[0].children[0].text #(Unit type rendering JS Script in string)
			floor_plans[:price_script] = fp.xpath(".//div[@class='\\\"spec'][@spec-sm='']/script")[0].children[0].text #(Unit type rendering JS Script in string)

			data[:floorPlans] << floor_plans
		end
	end
end
