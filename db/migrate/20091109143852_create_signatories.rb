class CreateSignatories < ActiveRecord::Migration
  def self.up
    create_table :signatories do |t|
      t.string :date
      t.string :type
      t.string :member_name
      t.string :member_xml_id
    end
  end

  def self.down
    drop_table :signatories
  end
end
