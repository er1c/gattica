# -*- encoding: utf-8 -*-
 
Gem::Specification.new do |s|
  s.name = 'gattica'
  s.version = "0.1.4"
 
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ['Rob Cameron']
  s.date = '2009-04-22'
  s.description = 'Gattica is a Ruby library for extracting data from the Google Analytics API.'
  s.email = 'cannikinn@gmail.com'
  s.files = ["History.txt", "README.rdoc", "LICENSE", "VERSION.yml", "examples/example.rb", "lib/gattica", "lib/gattica.rb", "lib/gattica/account.rb", "lib/gattica/auth.rb", "lib/gattica/convertible.rb", "lib/gattica/core_extensions.rb", "lib/gattica/data_point.rb", "lib/gattica/data_set.rb", "lib/gattica/exceptions.rb", "lib/gattica/user.rb", "test/helper.rb", "test/suite.rb", "test/test_sample.rb"]
  s.has_rdoc = true
  s.homepage = 'http://github.com/cannikin/gattica'
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.summary = 'Gattica is a Ruby library for extracting data from the Google Analytics API.'
  
  s.requirements << 'A Google Analytics Account'
  s.requirements << 'One or more Profiles that are being tracked in your GA account'
  
  s.add_dependency('hpricot','>= 0.8.1')
end
