require 'rails_helper'

RSpec.describe Sso::Warden::Hooks::BeforeLogout do

  let(:proc)            { described_class.to_proc }
  let(:calling)         { proc.call(user, warden, options) }
  let(:session_params)  { { "sso_session_id" => session.id } }
  let!(:session)        { Fabricate('Sso::Session') }

  let(:user)        { double :user }
  let(:warden)      { double :warden, request: {}, session: session_params, authenticated?: true }
  let(:options)     { { 'scope' => :user } }
  subject(:rack)    { described_class.new(user, warden, options) }

  before do
    Timecop.freeze
  end

  describe '.to_proc' do
    it 'is a proc' do
      expect(proc).to be_instance_of Proc
    end
  end

  describe '#call' do
    it 'accepts the three warden arguments and returns nothing' do
      expect(calling).to be_nil
    end

    context "when logged_in" do
      before() { allow(rack).to receive(:logged_in?).and_return(true) }

      it "run #logout" do
        expect(::Sso::Session).to receive(:logout).with(session.id)
        calling
      end

      it 'revokes the passport' do
        rack.call
        session.reload
        expect(session.revoked_at.to_i).to eq Time.now.to_i
        expect(session.revoke_reason).to eq 'logout'
      end
    end

    context "when logged_out" do
      before() { allow(rack).to receive(:logged_in?).and_return(false) }

      it 'no error occurs' do
        expect(rack.call).to be_nil
      end
    end
  end


end
