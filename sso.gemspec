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

  s.add_dependency "rails", "~> 4.2.1"

  s.add_development_dependency "sqlite3"
end
