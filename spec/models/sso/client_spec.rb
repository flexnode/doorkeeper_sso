require 'rails_helper'

RSpec.describe Sso::Client, :type => :model do
  let(:user) { Fabricate(:user) }
  let(:application) { Fabricate('Doorkeeper::Application') }
  let(:access_token) { Fabricate('Doorkeeper::AccessToken',
                                 resource_owner_id: user.id) }
  let(:access_grant) { Fabricate('Doorkeeper::AccessGrant',
                                 application_id: application.id,
                                 resource_owner_id: user.id,
                                 redirect_uri: 'http://localhost:3002/oauth/callback'
                                ) }

  # Set up Session
  let(:session) {  Fabricate('Sso::Session', owner: user) }


  describe "associations" do
    it { is_expected.to belong_to(:session).class_name('Sso::Session').with_foreign_key(:sso_session_id) }
    it { is_expected.to belong_to(:application).class_name('Doorkeeper::Application') }
    it { is_expected.to belong_to(:access_grant).class_name('Doorkeeper::AccessGrant') }
    it { is_expected.to belong_to(:access_token).class_name('Doorkeeper::AccessToken') }
  end

  describe "validations" do
    it { is_expected.to validate_uniqueness_of(:access_grant_id).allow_nil }
    it { is_expected.to validate_uniqueness_of(:access_token_id).allow_nil }
  end

  describe "::find_by_grant_token" do
    subject!(:client) {  Fabricate('Sso::Client', session: session,
                                application_id: application.id,
                                access_grant_id: access_grant.id,
                                access_token_id: access_token.id) }

    it { expect(::Sso::Client.find_by_grant_token(access_grant.token)).to eq client}
  end

  describe "::find_by_access_token" do
    subject!(:client) {  Fabricate('Sso::Client', session: session,
                                application_id: application.id,
                                access_grant_id: access_grant.id,
                                access_token_id: access_token.id) }

    it { expect(::Sso::Client.find_by_access_token(access_token.token)).to eq client }
  end


  describe "#update_access_token" do
    subject!(:client) {  Fabricate('Sso::Client', session: session,
                                application_id: application.id,
                                access_grant_id: access_grant.id) }

    it "updates client with access token" do
      expect(client.update_access_token(access_token.token)).to be_truthy
      expect(client.access_token).to eq access_token
    end
  end
end
