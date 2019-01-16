# JSON web token related configurations

Rails.application.config.jwt_key = ENV.fetch('JWT_KEY', 'super_secret_string')
