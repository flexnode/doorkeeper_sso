Fabricator('Sso::Session') do
  application_id { 0 }
  owner { Fabricate(:user) }
  clients { [ Fabricate('Sso::Client') ] }
end
