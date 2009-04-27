module Gattica
  
  # Represents a user to be authenticated by GA
  
  class User
  
    include Convertible
  
    attr_accessor :email, :password
  
    def initialize(email,password)
      @email = email
      @password = password
      validate
    end
    
    # User gets a special +to_h+ because Google expects +Email+ and +Passwd+ instead of our nicer internal names
    def to_h
      { :Email => @email,
        :Passwd => @password }
    end
    
    private
    # Determine whether or not this is a valid user
    def validate
      raise GatticaError::InvalidEmail, "The email address '#{@email}' is not valid" if not @email.match(/^(?:[_a-z0-9-]+)(\.[_a-z0-9-]+)*@([a-z0-9-]+)(\.[a-zA-Z0-9\-\.]+)*(\.[a-z]{2,4})$/i)
      raise GatticaError::InvalidPassword, "The password cannot be blank" if @password.empty? || @password.nil?
    end
  
  end
end
