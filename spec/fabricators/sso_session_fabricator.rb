Fabricator('Sso::Session') do
  application_id { 0 }
  ip { "127.0.0.1" }
  agent { "Mozilla Firefox" }
  owner { Fabricate(:user) }
end
