class ChangeSignaturesDateToDatetime < ActiveRecord::Migration
  def self.up
    remove_column :signatures, :date
    add_column :signatures, :date, :date
  end

  def self.down
    remove_column :signatures, :date
    add_column :signatures, :date, :string
  end
end
