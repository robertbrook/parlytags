class AddSessionIdToEdms < ActiveRecord::Migration
  def self.up
    add_column :edms, :session_id, :integer
    remove_column :edms, :session
  end

  def self.down
    remove_column :edms, :session_id
    add_column :edms, :session, :string
  end
end
