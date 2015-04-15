Fabricator('Doorkeeper::Application') do
  name { sequence(:name) { |n| "Application #{n}" } }
  app_uri {  'https://app.com/callback' }
  redirect_uri { 'https://app.com/callback' }
end
