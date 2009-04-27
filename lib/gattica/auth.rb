require 'net/http'
require 'net/https'

module Gattica
  
  # Authenticates a user against the Google Client Login system
  
  class Auth
    
    include Convertible

    SCRIPT_NAME = '/accounts/ClientLogin'
    HEADERS = { 'Content-Type' => 'application/x-www-form-urlencoded', 'User-Agent' => 'Ruby Net::HTTP' }   # Google asks that you be nice and provide a user-agent string
    OPTIONS = { :source => 'gattica-'+VERSION, :service => 'analytics' }                                    # Google asks that you provide the name of your app as a 'source' parameter in your POST

    attr_reader :response, :data, :tokens, :token
  
    # Prepare the user info along with options and header
    def initialize(http, user)
      data = OPTIONS.merge(user.to_h)
      @response, @data = http.post(SCRIPT_NAME, data.to_query, HEADERS)
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
