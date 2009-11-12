class RenameTypeToSignatoryType < ActiveRecord::Migration
  def self.up
    rename_column :signatories, :type, :signatory_type
  end

  def self.down
    rename_column :signatories, :signatory_type, :type
  end
end
