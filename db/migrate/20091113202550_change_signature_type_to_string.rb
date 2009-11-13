class ChangeSignatureTypeToString < ActiveRecord::Migration
  def self.up
    change_column :member_signatures, :signature_type, :string
  end

  def self.down
    change_column :member_signatures, :signature_type, :integer
  end
end
