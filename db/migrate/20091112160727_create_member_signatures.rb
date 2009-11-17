class CreateMemberSignatures < ActiveRecord::Migration
  def self.up
    create_table :member_signatures do |t|
      t.integer :edm_id
      t.integer :signature_id
      t.integer :signature_type
    end
  end

  def self.down
    drop_table :member_signatures
  end
end
