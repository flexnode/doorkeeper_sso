Fabricator('Doorkeeper::AccessGrant') do
  application { Fabricate("Doorkeeper::Application") }
  expires_in { 2.hours }
end
