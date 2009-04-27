require File.join(File.dirname(__FILE__), *%w[.. lib gattica])
 
require 'rubygems'
require 'test/unit'
require 'mocha'
 
# include Gattica
 
def fixture(name)
  File.read(File.join(File.dirname(__FILE__), 'fixtures', name))
end
 
def absolute_project_path
  File.expand_path(File.join(File.dirname(__FILE__), '..'))
end