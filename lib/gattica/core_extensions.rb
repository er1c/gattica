class Hash
  
  def to_query
    require 'cgi' unless defined?(CGI) && defined?(CGI::escape)
    self.collect do |key, value|
      "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
    end.sort * '&'
  end
  
  def key
    self.keys.first if self.length == 1
  end

  def value
    self.values.first if self.length == 1
  end
  
  def stringify_keys
    inject({}) do |options, (key, value)|
      options[key.to_s] = value
      options
    end
  end

end
