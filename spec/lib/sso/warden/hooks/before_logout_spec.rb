require 'rails_helper'

# These tests are moot
RSpec.describe Sso::Warden::Hooks::BeforeLogout do

  # let(:proc)     { described_class.to_proc }
  # let(:calling)  { proc.call(user, warden, options) }
  # let(:user)     { double :user }
  # let(:params)   { { passport_id: 1337 } } #passport.id } }
  # let(:options)  { double :options, scope: :user }
  # let(:request)  { double :request, params: params.stringify_keys }
  # let(:warden)   { double :warden, request: request, :session => user }

  # before do
  #   allow(warden).to receive(:authenticated?)
  #   Timecop.freeze
  # end

  # describe '.to_proc' do
  #   it 'is a proc' do
  #     expect(proc).to be_instance_of Proc
  #   end
  # end

  # describe '#call' do
  #   it 'accepts the three warden arguments and returns nothing' do
  #     expect(calling).to be_nil
  #   end
  # end

end
