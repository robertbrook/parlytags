class RenameMemberSignaturesToMotionSignatures < ActiveRecord::Migration
  def self.up
    rename_table :member_signatures, :motion_signatures
  end

  def self.down
    rename_table :motion_signatures, :member_signatures
  end
end
