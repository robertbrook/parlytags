class DropEdmsSignatories < ActiveRecord::Migration
  def self.up
    drop_table :edms_signatories
  end

  def self.down
    create_table :edms_signatories, :id => false do |t|
      t.integer :edm_id
      t.integer :signatory_id
    end
  end
end
