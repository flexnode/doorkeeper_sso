class RemoveExtraColumnsFromSsoSessions < ActiveRecord::Migration
  def change
    change_table(:sso_sessions) do |t|
      t.remove :ip
      t.remove :agent
      t.remove :location
    end
  end
end
