$:.unshift File.dirname(__FILE__) # for use/testing when no gem is installed

# external
require 'net/http'
require 'net/https'
require 'uri'
require 'logger'
require 'rubygems'
require 'hpricot'

# internal
require 'gattica/core_extensions'
require 'gattica/convertible'
require 'gattica/exceptions'
require 'gattica/user'
require 'gattica/auth'
require 'gattica/account'
require 'gattica/data_set'
require 'gattica/data_point'

# Gattica is a Ruby library for talking to the Google Analytics API.
#
# = Introduction
# There are generally three steps to getting info from the GA API:
# 
# 1. Authenticate
# 2. Get a profile id
# 3. Get the data you really want
# 
# = Usage
# This library does all three. A typical transaction will look like this:
# 
#  gs = Gattica.new('johndoe@google.com','password',123456)
#  results = gs.get({ :start_date => '2008-01-01', 
#                     :end_date => '2008-02-01', 
#                     :dimensions => 'browser', 
#                     :metrics => 'pageviews', 
#                     :sort => 'pageviews'})
# 
# So we instantiate a copy of Gattica and pass it a Google Account email address and password.
# The third parameter is the profile_id that we want to access data for. (If you don't know what
# your profile_id is [and you probably don't since GA doesn't tell you except through this API]
# then check out Gattica::Engine#accounts).
# 
# Then we call +get+ with the parameters we want to shape our data with. In this case we want
# total page views, broken down by browser, from Jan 1 2008 to Feb 1 2008, sorted by page views.
# 
# If you don't know the profile_id you want to get data for, call +accounts+
# 
#  gs = Gattica.new('johndoe@google.com','password')
#  accounts = gs.accounts
# 
# This returns all of the accounts and profiles that the user has access to. Note that if you
# use this method to get profiles, you need to manually set the profile before you can call +get+
# 
#  gs.profile_id = 123456
#  results = gs.get({ :start_date => '2008-01-01', 
#                     :end_date => '2008-02-01', 
#                     :dimensions => 'browser', 
#                     :metrics => 'pageviews', 
#                     :sort => 'pageviews'})


module Gattica
  
  VERSION = '0.1.3'
  LOGGER = Logger.new(STDOUT)

  def self.new(*args)
    Engine.new(*args)
  end
  
  # The real meat of Gattica, deals with talking to GA, returning and parsing results.
  
  class Engine
    
    SERVER = 'www.google.com'
    PORT = 443
    SECURE = true
    DEFAULT_ARGS = { :start_date => nil, :end_date => nil, :dimensions => [], :metrics => [], :filters => [], :sort => [] }
    
    attr_reader :user, :token
    attr_accessor :profile_id
    
    # Create a user, and get them authorized.
    # If you're making a web app you're going to want to save the token that's returned by this
    # method so that you can use it later (without having to re-authenticate the user each time)
    #
    #   ga = Gattica.new('johndoe@google.com','password',123456)
    #   ga.token => 'DW9N00wenl23R0...' (really long string)
    
    def initialize(email,password,profile_id=0,debug=false)
      LOGGER.datetime_format = '' if LOGGER.respond_to? 'datetime_format'
      
      @profile_id = profile_id
      @user_accounts = nil
      
      # save an http connection for everyone to use
      @http = Net::HTTP.new(SERVER, PORT)
      @http.use_ssl = SECURE
      @http.set_debug_output $stdout if debug
      
      # create a user and authenticate them
      @user = User.new(email, password)
      @auth = Auth.new(@http, user, { :source => 'active-gattica-0.1' }, { 'User-Agent' => 'ruby 1.8.6 (2008-03-03 patchlevel 114) [universal-darwin9.0] Net::HTTP' })
      @token = @auth.tokens[:auth]
      @headers = { 'Authorization' => "GoogleLogin auth=#{@token}" }
      
      # TODO: check that the user has access to the specified profile and show an error here rather than wait for Google to respond with a message
    end
    
    
    # Returns the list of accounts the user has access to. A user may have multiple accounts on Google Analytics
    # and each account may have multiple profiles. You need the profile_id in order to get info from GA. If you
    # don't know the profile_id then use this method to get a list of all them. Then set the profile_id of your
    # instance and you can make regular calls from then on.
    #
    #   ga = Gattica.new('johndoe@google.com','password')
    #   ga.get_accounts
    #   # you parse through the accounts to find the profile_id you need
    #   ga.profile_id = 12345678
    #   # now you can perform a regular search, see Gattica::Engine#get
    #
    # If you pass in a profile id when you instantiate Gattica::Search then you won't need to
    # get the accounts and find a profile_id - you apparently already know it!
    #
    # See Gattica::Engine#get to see how to get some data.
    
    def accounts
      # if we haven't retrieved the user's accounts yet, get them now and save them
      if @accts.nil?
        response, data = @http.get('/analytics/feeds/accounts/default', @headers)
        xml = Hpricot(data)
        @user_accounts = xml.search(:entry).collect { |entry| Account.new(entry) }
      end
      return @user_accounts
    end
    
    
    # This is the method that performs the actual request to get data.
    #
    # == Usage
    #
    #   gs = Gattica.new('johndoe@google.com','password',123456)
    #   gs.get({ :start_date => '2008-01-01', 
    #            :end_date => '2008-02-01', 
    #            :dimensions => 'browser', 
    #            :metrics => 'pageviews', 
    #            :sort => 'pageviews'})
    #
    # == Input
    #
    # When calling +get+ you'll pass in a hash of options. For a description of what these mean to 
    # Google Analytics, see http://code.google.com/apis/analytics/docs
    #
    # Required values are:
    #
    # * +start_date+ => Beginning of the date range to search within
    # * +end_date+ => End of the date range to search within
    #
    # Optional values are:
    #
    # * +dimensions+ => an array of GA dimensions (without the ga: prefix)
    # * +metrics+ => an array of GA metrics (without the ga: prefix)
    # * +filter+ => an array of GA dimensions/metrics you want to filter by (without the ga: prefix)
    # * +sort+ => an array of GA dimensions/metrics you want to sort by (without the ga: prefix)
    #
    # == Exceptions
    #
    # If a user doesn't have access to the +profile_id+ you specified, you'll receive an error.
    # Likewise, if you attempt to access a dimension or metric that doesn't exist, you'll get an
    # error back from Google Analytics telling you so.
    
    def get(args={})
      args = validate_and_clean(DEFAULT_ARGS.merge(args))
      query_string = build_query_string(args,@profile_id)
        LOGGER.debug(query_string)
      response, data = @http.get("/analytics/feeds/data?#{query_string}", @headers)
      begin
        response.value
      rescue Net::HTTPServerException => e
        raise GatticaError::AnalyticsError, data.to_s + " (status code: #{e.message})"
      end
      return DataSet.new(Hpricot.XML(data))
    end
    
    
    private
    # Creates a valid query string for GA
    def build_query_string(args,profile)
      output = "ids=ga:#{profile}&start-date=#{args[:start_date]}&end-date=#{args[:end_date]}"
      unless args[:dimensions].empty?
        output += '&dimensions=' + args[:dimensions].collect do |dimension|
          "ga:#{dimension}"
        end.join(',')
      end
      unless args[:metrics].empty?
        output += '&metrics=' + args[:metrics].collect do |metric|
          "ga:#{metric}"
        end.join(',')
      end
      unless args[:sort].empty?
        output += '&sort=' + args[:sort].collect do |sort|
          sort[0..0] == '-' ? "-ga:#{sort[1..-1]}" : "ga:#{sort}"  # if the first character is a dash, move it before the ga:
        end.join(',')
      end
      unless args[:filters].empty?    # filters are a little more complicated because they can have all kinds of modifiers
        
      end
      return output
    end
    
    
    # Validates that the args passed to +get+ are valid
    def validate_and_clean(args)
      
      raise GatticaError::MissingStartDate, ':start_date is required' if args[:start_date].nil? || args[:start_date].empty?
      raise GatticaError::MissingEndDate, ':end_date is required' if args[:end_date].nil? || args[:end_date].empty?
      raise GatticaError::TooManyDimensions, 'You can only have a maximum of 7 dimensions' if args[:dimensions] && (args[:dimensions].is_a?(Array) && args[:dimensions].length > 7)
      raise GatticaError::TooManyMetrics, 'You can only have a maximum of 10 metrics' if args[:metrics] && (args[:metrics].is_a?(Array) && args[:metrics].length > 10)
      
      # make sure that the user is only trying to sort fields that they've previously included with dimensions and metrics
      if args[:sort]
        possible = args[:dimensions] + args[:metrics]
        missing = args[:sort].find_all do |arg|
          !possible.include? arg.gsub(/^-/,'')    # remove possible minuses from any sort params
        end
        raise GatticaError::InvalidSort, "You are trying to sort by fields that are not in the available dimensions or metrics: #{missing.join(', ')}" unless missing.empty?
      end
      
      return args
    end
    
    
  end
end
