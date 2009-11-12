class DropSignatories < ActiveRecord::Migration
  def self.up
    drop_table :signatories
  end

  def self.down
    create_table :signatories do |t|
      t.string :date
      t.string :signatory_type
      t.string :member_name
      t.string :member_xml_id
    end
  end
end
