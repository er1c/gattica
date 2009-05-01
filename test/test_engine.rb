require File.dirname(__FILE__) + '/helper'
 
class TestEngine < Test::Unit::TestCase
  def setup
    
  end
  
  def test_initialization
    # assert Gattica.new({:email => 'anonymous@anon.com', :password => 'none'}) # you can initialize with a potentially invalid email and password
    assert Gattica.new({:token => 'test'})                                    # you can initialize with a potentially invalid token
    assert_raise GatticaError::NoLoginOrToken do Gattica.new() end            # but, you must initialize with one or the other
  end
  
end
