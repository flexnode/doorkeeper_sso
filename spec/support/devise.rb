module ControllerHelpers
  def sign_in(user = Fabricate(:user))
    if user.nil?
      allow(request.env['warden']).to receive(:authenticate!).
        and_throw(:warden, {:scope => :user})
      allow(controller).to receive_messages :current_user => nil
    else
      allow(request.env['warden']).to receive_messages :authenticate! => user
      allow(controller).to receive_messages :current_user => user
    end
  end
end

RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
  config.include ControllerHelpers, :type => :controller

  # rspec-rails 3 will no longer automatically infer an example group's spec type
  # from the file location. You can explicitly opt-in to the feature using this
  # config option.
  # To explicitly tag specs without using automatic inference, set the `:type`
  # metadata manually:
  #
  #     describe ThingsController, :type => :controller do
  #       # Equivalent to being in spec/controllers
  #     end
  config.infer_spec_type_from_file_location!
end
