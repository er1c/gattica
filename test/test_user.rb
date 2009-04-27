require File.dirname(__FILE__) + '/helper'
 
class TestUser < Test::Unit::TestCase
  def setup
    
  end
  
  def test_can_create_user
    assert Gattica::User.new('anonymous@anon.com','none')
  end
  
  def test_invalid_email
    assert_raise GatticaError::InvalidEmail do Gattica::User.new('','') end
    assert_raise ArgumentError do Gattica::User.new('') end
    assert_raise GatticaError::InvalidEmail do Gattica::User.new('anonymous','none') end
    assert_raise GatticaError::InvalidEmail do Gattica::User.new('anonymous@asdfcom','none') end
  end
    
  def test_invalid_password
    assert_raise GatticaError::InvalidPassword do Gattica::User.new('anonymous@anon.com','') end
    assert_raise ArgumentError do Gattica::User.new('anonymous@anon.com') end
  end
  
end
