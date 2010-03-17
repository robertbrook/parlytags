class CreateAlternateNames < ActiveRecord::Migration
  def self.up
    create_table :alternate_names, :force => true do |t|
      t.string  :name
      t.integer :place_id
    end
  end

  def self.down
    drop_table :alternate_names
  end
end
