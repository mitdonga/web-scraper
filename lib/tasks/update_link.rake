namespace :link do
	desc "Updating all links to add / at the end of url if it's not present"
	task update_link: :environment do 
		links = []
		Link.all.each do |link|
			unless link.url[-1] == "/"
				link.url = link.url.insert(-1, "/")
				link.save
				puts link.url
			end
		end

		puts links
	end

end

# Rake::Task["link:update_link"].execute
