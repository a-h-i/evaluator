Rails.application.routes.default_url_options[:host] = ENV.fetch('EVALUATOR_DOMAIN_NAME', 'localhost')
