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
        expect { Sso::Session.generate_master(nil) }.to raise_exception
      end
    end
  end

  # describe "::generate" do
  #   let(:master_sso_session) { Fabricate('Sso::Session') }
  #   let(:user) { Fabricate(:user) }
  #   let(:attributes) { { ip: "10.1.1.1", agent: "Safari" } }
  #   let(:access_token) { Fabricate("Doorkeeper::AccessToken", resource_owner_id: user.id) }
  #   let(:access_grant) { Fabricate('Doorkeeper::AccessGrant',
  #                                  application_id: nil,
  #                                  resource_owner_id: user.id,
  #                                  redirect_uri: 'http://localhost:3002/oauth/callback'
  #                                 ) }

  #   let(:session) { Sso::Session.generate(user, access_token, attributes) }

  #   before do
  #     master_sso_session.clients.create(access_token: access_token, access_grant: access_grant )
  #     # Notice: We assume our warden/doorkeeper is ok and a master with access grant/token is generated
  #     master_sso_session.access_token_id = access_token.id
  #     master_sso_session.access_grant_id = access_grant.id
  #     master_sso_session.save
  #   end

  #   describe "creates a new session" do
  #     it { expect(session.access_token_id).to eq access_token.id }
  #     it { expect(session.application_id).to eq access_token.application.id }
  #     it { expect(session.group_id).to eq master_sso_session.group_id }
  #   end
  # end

  describe "::logout" do
    let!(:sso_session) { Fabricate('Sso::Session') }
    let!(:user) { sso_session.owner }

    it "revokes session" do
      Sso::Session.logout(sso_session.id)
      new_session = Sso::Session.find(sso_session.id)
      expect(new_session.revoked_at).not_to be_blank
      expect(new_session.revoke_reason).to eq("logout")
    end
  end

  # describe "::update_master_with_grant" do
  #   let(:user) { Fabricate(:user) }
  #   let(:attributes) { { ip: "10.1.1.1", agent: "Safari" } }
  #   let(:access_token) { Fabricate("Doorkeeper::AccessToken", resource_owner_id: user.id) }
  #   let(:access_grant) { Fabricate('Doorkeeper::AccessGrant',
  #                                  application_id: nil,
  #                                  resource_owner_id: user.id,
  #                                  redirect_uri: 'http://localhost:3002/oauth/callback'
  #                                 ) }
  #   let!(:master_sso_session) { Sso::Session.generate_master(user, attributes) }

  #   context "successful" do
  #     it "updates master_sso_session.access_grant_id" do
  #       expect{ Sso::Session.update_master_with_grant(master_sso_session.id, access_grant) }.to change{ master_sso_session.reload.access_grant_id }.from(nil).to(access_grant.id)
  #     end
  #   end
  # end

  # describe "::update_master_with_access_token" do
  #   let(:user) { Fabricate(:user) }
  #   let(:attributes) { { ip: "10.1.1.1", agent: "Safari" } }
  #   let(:access_token) { Fabricate("Doorkeeper::AccessToken", resource_owner_id: user.id) }
  #   let(:access_grant) { Fabricate('Doorkeeper::AccessGrant',
  #                                  application_id: nil,
  #                                  resource_owner_id: user.id,
  #                                  redirect_uri: 'http://localhost:3002/oauth/callback'
  #                                 ) }
  #   let!(:master) { Sso::Session.generate_master(user, attributes) }

  #   before do
  #     # Notice: We assume our warden/doorkeeper is ok and a master with grant is generated
  #     master.access_grant_id = access_grant.id
  #     master.save
  #   end

  #   context "oauth_token not available" do
  #     it "returns false" do
  #       expect( Sso::Session.update_master_with_access_token(access_token.token, 123)).to be_falsey
  #     end
  #   end

  #   it "updates master.access_token_it" do
  #     expect{ Sso::Session.update_master_with_access_token(access_grant.token, access_token.token) }.to change{ master.reload.access_token_id }.from(nil).to(access_token.id)
  #   end
  # end

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
