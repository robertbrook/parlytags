class AddParentIdAndAmendmentNumberToEdms < ActiveRecord::Migration
  def self.up
    add_column :edms, :parent_id, :integer
    add_column :edms, :amendment_number, :integer
  end

  def self.down
    remove_column :edms, :parent_id
    remove_column :edms, :amendment_number
  end
end
