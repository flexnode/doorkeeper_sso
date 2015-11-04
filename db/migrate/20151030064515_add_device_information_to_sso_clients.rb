class AddDeviceInformationToSsoClients < ActiveRecord::Migration
  def change
    change_table :sso_clients do |t|
      t.string      "device_os"
      t.string      "device_os_version"
      t.string      "device_model"
      t.string      "random_token", null: false
    end
  end
end
