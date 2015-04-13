$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sso/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sso"
  s.version     = Sso::VERSION
  s.authors     = ["John Wong"]
  s.email       = ["john@flexnode.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Sso."
  s.description = "TODO: Description of Sso."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files  = Dir['spec/**/*'] & `git ls-files -z`.split("\0")

  s.add_dependency "rails", "~> 4.2.1"

  s.add_development_dependency "sqlite3"

  # Server
  s.add_runtime_dependency 'doorkeeper', '>= 2.0.0'

  # Client

  # Both
  s.add_runtime_dependency 'omniauth-oauth2'
  s.add_runtime_dependency 'signature', '>=  0.1.8'
  s.add_runtime_dependency 'warden', '>= 1.2.3'

  # Development
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'pg'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'simplecov', '>= 0.9.0'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'fabrication'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'nyan-cat-formatter'
end
