Fabricator('Doorkeeper::AccessToken') do
  resource_owner_id { Fabricate(:user).id }
  application { Fabricate("Doorkeeper::Application") }
  expires_in { 2.hours }
end
