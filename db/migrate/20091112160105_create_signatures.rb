class CreateSignatures < ActiveRecord::Migration
  def self.up
    create_table :signatures do |t|
      t.integer :member_id
      t.string  :date
      t.string  :type

      t.timestamps
    end
  end

  def self.down
    drop_table :signatures
  end
end
