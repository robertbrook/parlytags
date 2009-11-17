class CreateSessions < ActiveRecord::Migration
  def self.up
    create_table :sessions, :force => true do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :sessions
  end
end