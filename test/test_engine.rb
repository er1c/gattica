require File.dirname(__FILE__) + '/helper'
 
class TestActor < Test::Unit::TestCase
  def setup
    
  end
  
  def test_initializations
    # you can initialize with a potentially invalid email and password
    assert Gattica.new({:email => 'anonymous@anon.com', :password => 'none'})
    
    # you can initialize with a potentially invalid token
    assert Gattica.new({:token => 'test'})
    
    # but, you must include either an email/password or token to get started
    assert_raise GatticaError::NoLoginOrToken do
      Gattica.new()
    end
  end
  
end
