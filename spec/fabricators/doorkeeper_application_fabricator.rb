Fabricator('Doorkeeper::Application') do
  name { sequence(:name) { |n| "Application #{n}" } }
  app_uri {  'https://app.com/callback' }
  redirect_uri { 'https://app.com/callback' }
  pingback_uri { 'http://app.com/doorkeeper_sso_client/callback' }
end
