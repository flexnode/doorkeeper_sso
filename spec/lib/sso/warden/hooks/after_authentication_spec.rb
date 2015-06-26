require 'rails_helper'

RSpec.describe Sso::Warden::Hooks::AfterAuthentication do

  # Set up user
  let(:user) { Fabricate(:user) }
  # let(:application) { Fabricate('Doorkeeper::Application') }
  # let(:access_token) { Fabricate('Doorkeeper::AccessToken',
  #                                resource_owner_id: user.id) }
  # let!(:access_grant) { Fabricate('Doorkeeper::AccessGrant',
  #                                application_id: application.id,
  #                                resource_owner_id: user.id,
  #                                redirect_uri: 'http://localhost:3002/oauth/callback'
  #                               ) }

  # # Set up Session
  # let(:session) {  Fabricate('Sso::Session', owner: user) }
  # let!(:client) {  Fabricate('Sso::Client', session: session,
  #                               application_id: application.id,
  #                               access_token_id: access_token.id,
  #                               access_grant_id: access_grant.id) }

  # Set up rack
  let(:proc)           { described_class.to_proc }
  let(:session_params) { { } }
  let(:request)        { double :request, ip: "10.10.10.133", user_agent: "I AM YOUR BROWSER", session: session_params }
  let(:warden)         { double :warden, request: request, authenticated?: true }
  let(:options)        { { scope: :user } }
  subject(:rack)       { described_class.new(user, warden, options) }


  before do
    Timecop.freeze
    allow_any_instance_of(described_class).to receive(:session).and_return(session_params)
  end

  describe '::to_proc' do
    it 'is a proc' do
      expect(proc).to be_instance_of Proc
    end
  end

  describe "#call" do
    it 'accepts the three warden arguments and returns nothing' do
      expect(rack.call).to be_nil
    end

    it "run #generate_session" do
      expect(rack).to receive(:generate_session)
      rack.call
    end
  end

  describe '#generate_session' do
    it "generates master session" do
      expect(::Sso::Session).to receive(:generate_master).with( user, { ip: "10.10.10.133", agent: "I AM YOUR BROWSER" } ).and_call_original
      rack.call
    end

    it 'sets the session' do
      expect(rack.session["sso_session_id"]).to be_nil
      rack.call
      expect(rack.session["sso_session_id"]).to_not be_nil
    end
  end
end
