require 'rails_helper'

RSpec.describe 'OAuth 2.0 Authorization Grant Flow', type: :request, db: true do

  let!(:user)                     { Fabricate(:user, password: "bumblebee") }
  let!(:doorkeeper_application)   { Fabricate('Doorkeeper::Application') }
  let(:redirect_uri)              { doorkeeper_application.redirect_uri }

  let(:grant_params)        { { client_id: doorkeeper_application.uid, redirect_uri: redirect_uri, response_type: "code", state: 'some_random_string' } } # client_id=04364b30de79090493f079724571899eece7791b5af54e5866d73c6aaf167ec9&redirect_uri=http%3A%2F%2Flaunchpad.dev%2Fauth%2Fmindvalley%2Fcallback&response_type=code&state=a82b7b992c78ed7c47aba11340cdea76cc5ecc4ffe62ef39

  let(:result)              { JSON.parse(response.body) }

  let(:latest_grant)        { ::Doorkeeper::AccessGrant.last }
  let(:latest_access_token) { ::Doorkeeper::AccessToken.last }
  let(:access_token_count)  { ::Doorkeeper::AccessToken.count }
  let(:grant_count)         { ::Doorkeeper::AccessGrant.count }

  let(:latest_passport)     { ::SSO::Session.last }
  let(:passport_count)      { ::SSO::Session.last.count }

  before do
    get_via_redirect '/oauth/authorize', grant_params
  end

  it 'shows to the login page' do
    expect(response).to render_template 'devise/sessions/new'
  end

  describe 'Logging in' do
    before do
      post '/login', user: { email: user.email, password: "bumblebee" }
      follow_redirect!
    end

    it 'redirects to the application callback including the Grant Token' do
      #expect(latest_grant).to be_present
      expect(response.body).to eq 1 #redirect_to "#{doorkeeper_application.redirect_uri}?code=#{latest_grant.token}&state=some_random_string"
    end

    # it 'generates a passport with the grant token attached to it' do
    #   expect(latest_passport.oauth_access_grant_id).to eq latest_grant.id
    # end

    # it 'does not generate multiple authorization grants' do
    #   expect(grant_count).to eq 1
    # end

    pending 'Exchanging the Authorization Grant for an Access Token' do
      let(:grant)      { ::Rack::Utils.parse_query(URI.parse(response.location).query).fetch('code') }
      let(:grant_type) { :authorization_code }
      let(:params)     { { doorkeeper_application_id: doorkeeper_application.uid, doorkeeper_application_secret: doorkeeper_application.secret, code: grant, grant_type: grant_type, redirect_uri: redirect_uri } }
      let(:token)      { JSON.parse(response.body).fetch 'access_token' }

      before do
        post '/oauth/token', params
      end

      it 'succeeds' do
        expect(response.status).to eq 200
      end

      it 'responds with JSON serialized params' do
        expect(result).to be_instance_of Hash
      end

      it 'includes the access_token' do
        expect(result['access_token']).to eq latest_access_token.token
      end

      it 'generates a passport with the grant token attached to it' do
        expect(latest_passport.oauth_access_token_id).to eq latest_access_token.id
      end

      it 'does not generate multiple passports' do
        expect(passport_count).to eq 1
      end

      it 'does not generate multiple access tokens' do
        expect(access_token_count).to eq 1
      end

      it 'succeeds' do
        expect(response.status).to eq 200
      end

      pending 'Exchanging the Access Token for a Passport' do
        before do
          SSO.config.passport_chip_key = SecureRandom.hex
          post '/oauth/sso/v1/passports', access_token: token
        end

        it 'succeeds' do
          expect(response.status).to eq 200
        end

        it 'gets the passport' do
          expect(result['passport']).to be_present
        end

        it 'is the passport for that access token' do
          expect(result['passport']['id']).to eq latest_passport.id
          expect(latest_passport.oauth_access_token_id).to eq latest_access_token.id
        end

        pending 'is an outsider passport' do
          expect(latest_passport).to_not be_insider
        end

        pending 'insider application' do
          let!(:doorkeeper_application) { Fabricate('Doorkeeper::Application') }
          let(:scope)   { :insider }

          it 'is an insider passport' do
            expect(latest_passport).to be_insider
          end
        end
      end

    end
  end

end
