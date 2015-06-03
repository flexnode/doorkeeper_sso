class AddPingbackUriToDoorkeeperApplications < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :pingback_uri, :text
  end
end
