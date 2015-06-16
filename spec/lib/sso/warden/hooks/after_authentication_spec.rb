require 'rails_helper'

# These tests are moot
RSpec.describe Sso::Warden::Hooks::AfterAuthentication do
  #include Warden::Test::Helpers

  # let(:user) { Fabricate(:user) }
  # let(:warden_mock) { double }
  # let(:attributes) { { :ip => "202.188.0.133", :agent => "Chrome", format: :json } }

  # let(:after_authentication) { Sso::Warden::Hooks::AfterAuthentication.new(user, warden_mock, {:scope => :user}) }

  # let(:master_sso_session) { Sso::Session.generate_master(user, attributes) }
  # let(:access_token) { Fabricate("Doorkeeper::AccessToken",
  #                                resource_owner_id: user.id) }
  # let(:access_grant) { Fabricate('Doorkeeper::AccessGrant',
  #                                resource_owner_id: user.id,
  #                                redirect_uri: 'http://localhost:3002/oauth/callback'
  #                               ) }

  # before do
  #   master_sso_session.access_token_id = access_token.id
  #   master_sso_session.access_grant_id = access_grant.id
  #   master_sso_session.save
  # end

  # describe 'attributes' do
  #   it do
  #     expect(after_authentication.user).to eq user
  #     expect(after_authentication.warden).to eq warden_mock
  #     expect(after_authentication.options).to eq({})
  #   end
  # end

  # pending "#call"
end
