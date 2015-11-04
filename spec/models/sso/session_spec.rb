require 'rails_helper'

RSpec.describe Sso::Session, :type => :model do
  describe "associations" do
    it { is_expected.to belong_to(:application).class_name('Doorkeeper::Application') }
    it { is_expected.to belong_to(:access_grant).class_name('Doorkeeper::AccessGrant') }
    it { is_expected.to belong_to(:access_token).class_name('Doorkeeper::AccessToken') }
    it { is_expected.to belong_to(:owner).class_name('User') }
    it { is_expected.to have_many(:clients).class_name('Sso::Client').with_foreign_key(:sso_session_id) }
  end

  describe "validations" do
    pending { is_expected.to validate_presence_of(:secret) }
    it { is_expected.to allow_value(nil).for(:access_token_id) }
  end

  describe "scopes" do
    let(:session) { Fabricate('Sso::Session', revoked_at: nil, application_id: nil) }
    it { expect(Sso::Session.active).to eq [session] }
    it { expect(Sso::Session.master).to eq [session] }
  end

  describe "token based scopes" do

    let(:user) { Fabricate(:user) }
    let(:access_token) { Fabricate('Doorkeeper::AccessToken',
                                   resource_owner_id: user.id) }
    let(:access_grant) { Fabricate('Doorkeeper::AccessGrant',
                                   application_id: nil,
                                   resource_owner_id: user.id,
                                   redirect_uri: 'http://localhost:3002/oauth/callback'
                                  ) }

    let(:session) {  Fabricate('Sso::Session', owner: user) }
    let!(:client) {  Fabricate('Sso::Client', session: session,
                                  access_token_id: access_token.id,
                                  access_grant_id: access_grant.id) }

    describe "::with_token_id" do
      it { expect(Sso::Session.with_token_id(access_token.id).first).to eq session }
    end

    describe "::with_grant_id" do
      it { expect(Sso::Session.with_grant_id(access_grant.id).first).to eq session }
    end

    describe "::by_access_token" do
      it { expect(Sso::Session.by_access_token(access_token.token).first).to eq session }
    end
  end


  describe "::master_for" do
    let(:user) { Fabricate(:user) }
    let(:access_token) { Fabricate('Doorkeeper::AccessToken',
                                   resource_owner_id: user.id) }
    let(:access_grant) { Fabricate('Doorkeeper::AccessGrant',
                                   application_id: nil,
                                   resource_owner_id: user.id,
                                   redirect_uri: 'http://localhost:3002/oauth/callback'
                                  ) }

    let(:session) { Fabricate('Sso::Session',
                              revoked_at: nil,
                              application_id: nil,
                              access_token_id: access_token.id,
                              access_grant_id: access_grant.id,
                              owner: user) }

    it do
      expect(session.revoked_at).to be_nil
      expect(session.application_id).to be_nil
      expect(Sso::Session.master_for(access_grant.id)).to eq session
    end
  end

  describe "::generate_master" do
    let(:user) { Fabricate(:user) }
    let(:attributes) { { ip: "10.1.1.1", agent: "Safari" } }

    context "without access token" do
      it "creates a new session" do
        session = Sso::Session.generate_master(user, attributes)
        expect(session).to eq(Sso::Session.first)
      end

      it "creates a new sso_client" do
        session = Sso::Session.generate_master(user, attributes)
        expect(session.clients.first).to eq Sso::Client.first
      end
    end

    context "(failure)" do
      it "raises exception" do
        expect { Sso::Session.generate_master(nil, nil) }.to raise_exception(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe "::logout" do
    let(:user) { Fabricate(:user) }
    let(:access_token) { Fabricate('Doorkeeper::AccessToken',
                                   resource_owner_id: user.id) }
    let(:access_grant) { Fabricate('Doorkeeper::AccessGrant',
                                   application_id: nil,
                                   resource_owner_id: user.id,
                                   redirect_uri: 'http://localhost:3002/oauth/callback'
                                  ) }

    let(:sso_session) {  Fabricate('Sso::Session', owner: user) }
    let!(:sso_client) {  Fabricate('Sso::Client', session: sso_session,
                                  access_token_id: access_token.id,
                                  access_grant_id: access_grant.id) }

    it "revokes session and access token" do
      Sso::Session.logout(sso_session.id)
      new_session = Sso::Session.find(sso_session.id)

      expect(new_session.clients.count).to eq(2) # Should have 2 clients for a session
      expect(new_session.clients.with_access_token.first.access_token.revoked_at).not_to be_blank # Client access token should be revoked
      expect(new_session.revoked_at).not_to be_blank
      expect(new_session.revoke_reason).to eq("logout")
    end
  end

  describe "::active?" do
    context "active" do
      subject(:sso_session) { Fabricate('Sso::Session') }
      it { expect(sso_session.active?).to be_truthy }
    end

    context "inactive" do
      subject(:sso_session) { Fabricate('Sso::Session', revoked_at: Time.now, revoke_reason: "logout") }
      it { expect(sso_session.active?).to be_falsey }
    end
  end

end

# == Schema Information
# Schema version: 20150330031153
#
# Table name: sso_sessions
#
#  id              :uuid             not null, primary key
#  access_grant_id :integer
#  access_token_id :integer
#  application_id  :integer
#  owner_id        :integer          not null
#  group_id        :string           not null
#  secret          :string           not null
#  ip              :inet             not null
#  agent           :string
#  location        :string
#  activity_at     :datetime         not null
#  revoked_at      :datetime
#  revoke_reason   :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_sso_sessions_on_access_grant_id  (access_grant_id)
#  index_sso_sessions_on_access_token_id  (access_token_id)
#  index_sso_sessions_on_application_id   (application_id)
#  index_sso_sessions_on_group_id         (group_id)
#  index_sso_sessions_on_ip               (ip)
#  index_sso_sessions_on_owner_id         (owner_id)
#  index_sso_sessions_on_revoke_reason    (revoke_reason)
#  index_sso_sessions_on_secret           (secret)
#  one_access_token_per_owner             (owner_id,access_token_id,application_id) UNIQUE
#
