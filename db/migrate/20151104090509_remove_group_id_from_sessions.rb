class RemoveGroupIdFromSessions < ActiveRecord::Migration
  def change
    change_table :sso_sessions do |t|
      t.remove :group_id
    end
  end
end
