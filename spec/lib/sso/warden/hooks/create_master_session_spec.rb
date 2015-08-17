require 'rails_helper'

RSpec.describe Sso::Warden::Hooks::CreateMasterSession do

  # Set up user
  let(:user) { Fabricate(:user) }

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

    context 'existing session' do
      let(:sso_params) { { :ip => "202.188.0.133", :agent => "Chrome" } }
      let(:sso_session) { ::Sso::Session.generate_master(user, sso_params ) }
      let!(:session_params) { { "sso_session_id" => sso_session.id } }

      before() { rack.call }

      it { expect(::Sso::Session.count).to eq 2 }
      it { expect(::Sso::Session.find_by_id(sso_session.id).revoke_reason).to eq "logout" }

      it "runs Sso::Session.logout" do
        expect(::Sso::Session).to receive(:logout).with(nil)
        rack.call
      end
    end

    context 'logged out' do
      let(:user) { nil }

      before() { rack.call }

      it "will not run Sso::Session.logout" do
        expect(::Sso::Session).not_to receive(:logout)
        rack.call
      end

      it "will not run #generate_session" do
        expect(rack).not_to receive(:generate_session)
        rack.call
      end
    end

    it "runs Sso::Session.logout" do
      expect(::Sso::Session).to receive(:logout).with(nil)
      rack.call
    end

    it "runs #generate_session" do
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
