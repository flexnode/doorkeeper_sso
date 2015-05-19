require 'rails_helper'

RSpec.describe Sso::Client, :type => :model do
  describe "associations" do
    it { is_expected.to belong_to(:sso_session)}
    it { is_expected.to belong_to(:application).class_name('Doorkeeper::Application') }
    it { is_expected.to belong_to(:access_grant).class_name('Doorkeeper::AccessGrant') }
    it { is_expected.to belong_to(:access_token).class_name('Doorkeeper::AccessToken') }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:ip) }
  end
end
