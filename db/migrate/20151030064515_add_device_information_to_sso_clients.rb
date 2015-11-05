class AddDeviceInformationToSsoClients < ActiveRecord::Migration
  def change
    change_table :sso_clients do |t|
      t.string      "device_os"
      t.string      "device_os_version"
      t.string      "device_model"
      t.string      "random_token"
    end

    Sso::Client.find_each do |client|
      client.save
    end

    change_column :sso_clients, :random_token, :string, :null => true
  end
end
