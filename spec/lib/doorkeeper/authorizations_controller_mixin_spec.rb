require 'rails_helper'

# Engine.rb automatically includes the mixin

RSpec.describe Doorkeeper::AuthorizationsController do

  let(:user) { Fabricate(:user) }
  let(:application) { Fabricate('Doorkeeper::Application') }
  # let(:access_token) { Fabricate('Doorkeeper::AccessToken',
  #                                resource_owner_id: user.id) }
  let!(:access_grant) { Fabricate('Doorkeeper::AccessGrant',
                                 application_id: application.id,
                                 resource_owner_id: user.id,
                                 redirect_uri: 'http://localhost:3002/oauth/callback'
                                ) }

  # Set up Session
  let(:session) {  Fabricate('Sso::Session', owner: user) }
  let!(:client) {  Fabricate('Sso::Client', session: session,
                                application_id: application.id) }

  let(:auth) { double :auth, token: access_grant }
  let(:code_response)  { double :code_response, auth: auth }
  let(:authorization)  { double :authorization, instance_variable_get: code_response }
  let(:warden_session) { { "warden.user.user.session" => { "sso_session_id" => session.id } } }
  subject(:controller) { described_class.new }


  before do
    allow_any_instance_of(described_class).to receive(:authorization).and_return(authorization)
    allow_any_instance_of(described_class).to receive(:session).and_return(warden_session)
  end

  describe "working" do
    it "creates clint with grant_id" do
      controller.send(:after_grant_create)
      expect(access_grant.sso_client).to be_a ::Sso::Client
    end
  end

  describe "no grant" do
    let(:access_grant) { nil }

    it "logs out user" do
      expect(controller).to receive_message_chain("warden.logout")
      controller.send(:after_grant_create)
    end
  end

  describe "no session" do
    let(:warden_session) { {} }

    it "logs out user" do
      expect(controller).to receive_message_chain("warden.logout")
      controller.send(:after_grant_create)
    end
  end


end
