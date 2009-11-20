class ChangeSignaturesDateToDatetime < ActiveRecord::Migration
  def self.up
    change_column :signatures, :date, :date
  end

  def self.down
    change_column :signatures, :date, :string
  end
end
