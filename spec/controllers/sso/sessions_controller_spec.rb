require 'rails_helper'

RSpec.describe Sso::SessionsController, :type => :controller do
  routes { Sso::Engine.routes }
  render_views

  describe "GET id" do

    context "logged_in" do
      let(:user) { Fabricate(:user) }
      let(:application) { Fabricate('Doorkeeper::Application') }
      # let(:access_token) { Fabricate('Doorkeeper::AccessToken',
      #                                resource_owner_id: user.id) }
      # let(:access_grant) { Fabricate('Doorkeeper::AccessGrant',
      #                                application_id: application.id,
      #                                resource_owner_id: user.id,
      #                                redirect_uri: 'http://localhost:3002/oauth/callback'
      #                               ) }

      let(:session) {  Fabricate('Sso::Session', owner: user) }
      # let!(:client) {  Fabricate('Sso::Client', session: session,
      #                               application_id: application.id,
      #                               access_token_id: access_token.id,
      #                               access_grant_id: access_grant.id) }

      before(:each) do
        sign_in user
        allow(controller).to receive(:sso_session_id).and_return(session.id)
        get :id, format: :json
      end

      it "returns passport_id" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("sso_session_id")
      end
    end

    context "not logged_in" do
      it "returns not authorized" do
        get :id, format: :json
        expect(response).to have_http_status(:unauthorized)
        expect(response).to match_response_schema("error")
      end
    end
  end

  describe "GET show" do
    context "not logged_in" do
      it do
        get :show, format: :json
        expect(response).to have_http_status(:unauthorized)
        expect(response).to match_response_schema("error")
      end
    end

    context "logged_in" do
      let(:user) { Fabricate(:user) }
      let(:application) { Fabricate('Doorkeeper::Application') }
      # let(:access_token) { Fabricate('Doorkeeper::AccessToken',
      #                                resource_owner_id: user.id) }
      # let(:access_grant) { Fabricate('Doorkeeper::AccessGrant',
      #                                application_id: application.id,
      #                                resource_owner_id: user.id,
      #                                redirect_uri: 'http://localhost:3002/oauth/callback'
      #                               ) }

      let(:session) {  Fabricate('Sso::Session', owner: user) }
      # let!(:client) {  Fabricate('Sso::Client', session: session,
      #                               application_id: application.id,
      #                               access_token_id: access_token.id,
      #                               access_grant_id: access_grant.id) }

      before do
        sign_in user
        allow(controller).to receive(:sso_session_id).and_return(session.id)
        get :show, format: :json
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(assigns(:session)).to eq session }
      it { expect(response).to match_response_schema("sso_session") }
    end
  end

  describe "POST create" do
    let(:user) { Fabricate(:user) }
    let(:params) { { :ip => "202.188.0.133", :agent => "Chrome", format: :json } }

    context "not logged_in" do
      it do
        post :create, params
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "logged_in" do
      let(:user) { Fabricate(:user) }
      let(:master_sso_session) { Sso::Session.generate_master(user, { ip: "10.1.1.1", agent: "Safari" }) }
      let(:access_token) { Fabricate("Doorkeeper::AccessToken",
                                     resource_owner_id: user.id) }
      let(:access_grant) { Fabricate('Doorkeeper::AccessGrant',
                                     resource_owner_id: user.id,
                                     redirect_uri: 'http://localhost:3002/oauth/callback'
                                    ) }

      before do
        allow(controller).to receive(:doorkeeper_authorize!).and_return(true)
        allow(controller).to receive(:doorkeeper_token).and_return(access_token)

        # Create a client with access grant & access token
        master_sso_session.clients.find_or_create_by!(access_grant_id: access_grant.id, access_token_id: access_token.id)
        post :create, params
      end

      it { expect(response).to have_http_status(:created) }
      it { expect(assigns(:session)).to eq master_sso_session }
      it { expect(response).to match_response_schema("sso_client") }
      it { expect(master_sso_session.clients).to include ::Sso::Client.find_by(access_token: access_token) }
      it { expect(master_sso_session.clients.map(&:ip)).to include "202.188.0.133" }
    end
  end

end
