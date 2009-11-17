class CreateSessionSignatures < ActiveRecord::Migration
  create_table :session_signatures do |t|
    t.integer :session_id
    t.integer :signature_id
    t.integer :signature_type
  end

  def self.down
    drop_table :session_signatures
  end
end
