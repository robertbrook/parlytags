class AddSessionIdToSignatures < ActiveRecord::Migration
  def self.up
    add_column :signatures, :session_id, :integer
  end

  def self.down
    remove_column :signatures, :session_id
  end
end
