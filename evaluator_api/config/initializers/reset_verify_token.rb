Rails.application.config.verification_token_str_max_length = ENV.fetch('VERIFICATION_TOKEN_STR_MAX_LENGTH', 30)
Rails.application.config.pass_reset_token_str_max_length = ENV.fetch('PASS_RESET_TOKEN_STR_MAX_LENGTH', 30)
