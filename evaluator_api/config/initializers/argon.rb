Rails.application.config.argon =  Rails.application.config_for(:argon, env: 'argon').symbolize_keys
