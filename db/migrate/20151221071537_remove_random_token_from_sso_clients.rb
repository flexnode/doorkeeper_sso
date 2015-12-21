class RemoveRandomTokenFromSsoClients < ActiveRecord::Migration
  def change
    change_table :sso_clients do |t|
      t.remove :random_token
    end
  end
end
