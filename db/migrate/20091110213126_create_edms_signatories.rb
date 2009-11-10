class CreateEdmsSignatories < ActiveRecord::Migration
  def self.up
    create_table :edms_signatories, :id => false do |t|
      t.integer :edm_id
      t.integer :signatory_id
    end
  end

  def self.down
    drop_table :edms_signatories
  end
end
