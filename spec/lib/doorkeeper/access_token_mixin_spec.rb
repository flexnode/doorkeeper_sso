require 'rails_helper'

# Engine.rb automatically includes the mixin

RSpec.describe Doorkeeper::AccessToken, :type => :model do
  describe "associations" do
    it { is_expected.to have_many(:sso_clients).class_name('Sso::Client').with_foreign_key(:access_token_id) }
  end

  describe "assignment" do
    let(:user) { Fabricate(:user) }
    let(:application) { Fabricate('Doorkeeper::Application') }
    let(:access_token) { Fabricate('Doorkeeper::AccessToken',
                                   resource_owner_id: user.id) }
    let(:access_grant) { Fabricate('Doorkeeper::AccessGrant',
                                   application_id: application.id,
                                   resource_owner_id: user.id,
                                   redirect_uri: 'http://localhost:3002/oauth/callback'
                                  ) }

    let(:session) {  Fabricate('Sso::Session', owner: user) }
    let!(:client) {  Fabricate('Sso::Client', session: session,
                                  application_id: application.id,
                                  access_token_id: access_token.id,
                                  access_grant_id: access_grant.id) }

    it { expect(access_token.sso_clients).to eq [ client ] }
  end
end
