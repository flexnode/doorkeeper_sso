require 'rails_helper'

# Engine.rb automatically includes the mixin

RSpec.describe Doorkeeper::TokensController, :type => :controller do

  let(:user) { Fabricate(:user) }
  let(:application) { Fabricate('Doorkeeper::Application') }
  let(:access_token) { Fabricate('Doorkeeper::AccessToken',
                                 resource_owner_id: user.id) }
  let!(:access_grant) { Fabricate('Doorkeeper::AccessGrant',
                                 application_id: application.id,
                                 resource_owner_id: user.id,
                                 redirect_uri: 'http://localhost:3002/oauth/callback'
                                ) }

  # Set up Session
  let(:session) {  Fabricate('Sso::Session', owner: user) }
  let!(:client) {  Fabricate('Sso::Client', session: session,
                                application_id: application.id,
                                access_grant_id: access_grant.id) }

  let(:auth) { double :auth, token: access_grant }
  let(:code_response)  { double :code_response, auth: auth }
  let(:authorization)  { double :authorization, instance_variable_get: code_response }
  let(:warden_session) { { "warden.user.user.session" => { "sso_session_id" => session.id } } }
  subject(:controller) { described_class.new }


  describe "#handle_authorization_grant_flow" do
    before do
      allow(controller).to receive(:grant_token).and_return(access_grant.try(:token))
      allow(controller).to receive(:grant_type).and_return("authorization_code")
      allow(controller).to receive(:outgoing_access_token).and_return(access_token.try(:token))
    end

    context "working flow" do
      it "saves access_token" do
        controller.send(:handle_authorization_grant_flow)
        client.reload
        expect(client.access_grant).to eq access_grant
      end
    end

    context "grant missing" do
      let!(:access_grant) { nil }
      let!(:client) { nil }

      it "logs error and halt" do
        expect(controller).to receive(:error)
        expect(controller.send(:handle_authorization_grant_flow)).to be_falsy
      end
    end

    context "access_grant token missing" do
      let(:access_token) { nil }

      it "logs error and halt" do
        expect(controller).to receive(:error)
        expect(controller.send(:handle_authorization_grant_flow)).to be_falsy
      end
    end
  end


  describe "#error_and_return" do
    after()  { controller.send(:error_and_return, "AN ERROR") }

    it { expect(controller).to receive(:error) }
  end

end
