class ChangeSignaturesDateToDatetime < ActiveRecord::Migration
  def self.up
    change_column :signatures, :date, :datetime
  end

  def self.down
    change_column :signatures, :date, :string
  end
end
