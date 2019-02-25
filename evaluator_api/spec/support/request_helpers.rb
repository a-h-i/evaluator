module Request
  module HeaderHelpers
    def set_token(token)
      request.headers['Authorization'] = "Bearer #{token}"
    end
  end
  module JsonHelpers
    def json_response
      JSON.parse(response.body, symbolize_names: true)
    end
  end
end