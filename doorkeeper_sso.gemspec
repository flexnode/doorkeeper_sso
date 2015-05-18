$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sso/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "doorkeeper_sso"
  s.version     = Sso::VERSION
  s.authors     = ["John Wong"]
  s.email       = ["john@flexnode.com"]
  s.summary     = 'Leveraging Doorkeeper as single-sign-on OAuth server.'
  s.description = "#{s.summary} To provide true single-sign-OUT, every request on an OAuth client app is verified with the SSO server."
  s.license     = "MIT"
  s.homepage    = 'https://github.com/flexnode/doorkeeper-sso'

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files  = Dir['spec/**/*'] & `git ls-files -z`.split("\0")

  s.required_ruby_version = '>= 1.9'

  s.add_dependency "rails", ">= 4.0"
  s.add_dependency 'devise', '>= 3.4'
  s.add_dependency 'doorkeeper', '>= 2.0.0'

  s.add_runtime_dependency 'omniauth-oauth2', '>= 1.2'
  s.add_runtime_dependency 'signature', '>=  0.1.8'
  s.add_runtime_dependency 'warden', '>= 1.2.3'

  # Development
  s.add_development_dependency 'database_cleaner', '>= 1.4'
  s.add_development_dependency 'pg', '>= 0.18'
  s.add_development_dependency 'rspec-rails', '>= 3.0'
  s.add_development_dependency 'shoulda-matchers', '>= 2.8'
  s.add_development_dependency 'simplecov', '>= 0.9.0'
  s.add_development_dependency 'timecop', '>= 0.7'
  s.add_development_dependency 'webmock', '>= 1.2'
  s.add_development_dependency 'fabrication', '>= 2.0'
  s.add_development_dependency 'vcr', '>= 2.9'
  s.add_development_dependency 'nyan-cat-formatter', '>= 0.11'
  s.add_development_dependency 'combustion', '~> 0.5.3'
  s.add_development_dependency 'ffaker', '>= 1'
end
