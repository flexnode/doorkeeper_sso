require 'rails_helper'

RSpec.describe Sso::Client, :type => :model do
  describe "associations" do
    it { is_expected.to belong_to(:session).class_name('Sso::Session').with_foreign_key(:sso_session_id) }
    it { is_expected.to belong_to(:application).class_name('Doorkeeper::Application') }
    it { is_expected.to belong_to(:access_grant).class_name('Doorkeeper::AccessGrant') }
    it { is_expected.to belong_to(:access_token).class_name('Doorkeeper::AccessToken') }
  end
end
