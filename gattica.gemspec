# -*- encoding: utf-8 -*-
 
Gem::Specification.new do |s|
  s.name = %q{gattica}
  s.version = "0.1.2"
 
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Rob Cameron"]
  s.date = %q{2009-04-22}
  s.description = %q{Gattica is a Ruby library for extracting data from the Google Analytics API.}
  s.email = %q{cannikinn@gmail.com}
  s.files = ["History.txt", "README.rdoc", "LICENSE", "VERSION.yml", "examples/example.rb", "lib/gattica", "lib/gattica.rb", "lib/gattica/account.rb", "lib/gattica/auth.rb", "lib/gattica/convertible.rb", "lib/gattica/core_extensions.rb", "lib/gattica/data_point.rb", "lib/gattica/data_set.rb", "lib/gattica/exceptions.rb", "lib/gattica/user.rb", "test/fixtures", "test/helper.rb", "test/suite.rb", "test/test_sample.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/cannikin/gattica}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{gattica}
  s.rubygems_version = %q{0.1.2}
  s.summary = %q{Gattica is a Ruby library for extracting data from the Google Analytics API.}
 
  #if s.respond_to? :specification_version then
  #  current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
  #  s.specification_version = 2
  #
  #  if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
  #    s.add_runtime_dependency(%q<mime-types>, [">= 1.15"])
  #    s.add_runtime_dependency(%q<diff-lcs>, [">= 1.1.2"])
  #  else
  #    s.add_dependency(%q<mime-types>, [">= 1.15"])
  #    s.add_dependency(%q<diff-lcs>, [">= 1.1.2"])
  #  end
  #else
  #  s.add_dependency(%q<mime-types>, [">= 1.15"])
  #  s.add_dependency(%q<diff-lcs>, [">= 1.1.2"])
  #end
end
