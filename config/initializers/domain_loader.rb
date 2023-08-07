
domain_file_path = Rails.root.join('config', 'allowed_domains.txt')

allowed_domains = File.readlines(domain_file_path).map(&:strip)

Rails.application.config.allowed_domains = allowed_domains