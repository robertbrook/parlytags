class CreateSignatories < ActiveRecord::Migration
  def self.up
    create_table :signatories do |t|
      t.integer :edm_id
      t.integer :member_id
      t.string :date
      t.string :type
      
      t.timestamps
    end
  end

  def self.down
    drop_table :signatories
  end
end
