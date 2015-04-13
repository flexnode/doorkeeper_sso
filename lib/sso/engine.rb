module Sso
  class Engine < ::Rails::Engine
    isolate_namespace Sso

    # Generators for Rspec and Fabrication
    config.generators do |g|
      g.test_framework  :rspec,
                        :fixtures => true,
                        :view_specs => false,
                        :helper_specs => false,
                        :routing_specs => false,
                        :controller_specs => true,
                        :request_specs => false
      g.fixture_replacement :fabrication
    end
  end
end
