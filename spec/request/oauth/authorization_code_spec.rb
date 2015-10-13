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

  let(:latest_session)     { ::Sso::Session.last }
  let(:session_count)      { ::Sso::Session.count }

  before do
    get_via_redirect '/oauth/authorize', grant_params
  end

  it 'shows to the login page' do
    expect(response).to render_template 'devise/sessions/new'
  end

  describe 'Logging in' do
    before(:each) do
      post '/users/sign_in', user: { email: user.email, password: "bumblebee" }
      follow_redirect!
    end

    it 'redirects to the application callback including the Grant Token' do
      is_expected.to redirect_to "#{doorkeeper_application.redirect_uri}?code=#{latest_grant.token}&state=some_random_string"
    end

    it 'generates a master session' do
      expect(session_count).to eq 1
    end

    it 'generates a master client and a child client' do
      expect(latest_session.clients.count).to eq 2
    end

    it 'child client have grant token info attached to it' do
      expect(latest_session.clients.with_access_grant.count).to eq 1
      expect(latest_session.clients.with_access_grant.first.access_grant_id).to eq latest_grant.id
    end

    it 'does not generate multiple authorization grants' do
      expect(grant_count).to eq 1
    end

    context 'Exchanging the Authorization Grant for an Access Token' do
      let(:grant)      { ::Rack::Utils.parse_query(URI.parse(response.location).query).fetch('code') }
      let(:grant_type) { :authorization_code }
      let(:token_params)     { { client_id: doorkeeper_application.uid, client_secret: doorkeeper_application.secret, code: grant, grant_type: grant_type, redirect_uri: redirect_uri } }
      let(:token)      { JSON.parse(response.body).fetch 'access_token' }

      before(:each) do
        post '/oauth/token', token_params
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

      it 'does not generate multiple master session' do
        expect(session_count).to eq 1
      end

      it 'does not generate another client' do
        expect(latest_session.clients.count).to eq 2
      end

      it 'updates child client with the access token info' do
        expect(latest_session.clients.with_access_token.first.access_token_id).to eq latest_access_token.id
      end

      context 'Updates the child client with user info' do
        let(:client_params)     { { access_token: token, ip: "127.0.0.1", agent: "curl/7.43.0" } }

        before(:each) do
          post '/sso/sessions', client_params
        end

        it 'succeeds' do
          expect(response.status).to eq 201
        end

        it 'child client is updated with user info' do
          child_client = latest_session.clients.with_access_token.first
          expect(child_client.ip).to eq "127.0.0.1"
          expect(child_client.agent).to eq "curl/7.43.0"
        end
      end

    end
  end

end
