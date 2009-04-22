require 'net/http'
require 'net/https'

module Gattica
  
  # Authenticates a user against the Google Client Login system
  
  class Auth
    
    include Convertible

    SCRIPT_NAME = '/accounts/ClientLogin'
    HEADERS = { 'Content-Type' => 'application/x-www-form-urlencoded' }
    OPTIONS = { :source => '', :service => 'analytics' }
  
    attr_reader :response, :data, :tokens, :token
  
    # Prepare the user info along with options and header
    def initialize(http, user, options={}, headers={})
      data = OPTIONS.merge(options)
      data = data.merge(user.to_h)
      headers = HEADERS.merge(headers)
    
      @response, @data = http.post(SCRIPT_NAME, data.to_query, headers)
      @tokens = parse_tokens(@data)
    end
  
    private
    # Parse the authentication tokens out of the response
    def parse_tokens(data)
      tokens = {}
      data.split("\n").each do |t|
        tokens.merge!({ t.split('=').first.downcase.to_sym => t.split('=').last })
      end
      return tokens
    end
  
  end
end
