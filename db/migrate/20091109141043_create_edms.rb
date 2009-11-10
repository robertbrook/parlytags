class CreateEdms < ActiveRecord::Migration
  def self.up
    create_table :edms do |t|
      t.integer :motion_xml_id
      t.string :session
      t.string :number
      t.string :title
      t.text :text
      t.integer :signature_count
      
      t.timestamps
    end
  end

  def self.down
    drop_table :edms
  end
end

# Example fragment

# <id>13298</id>
# <session>1996-1997</session>
# <number>632A3</number>
# <title>Constitutional Change;amdt. Line 3: </title>
# <text>leave out `is long overdue' and insert `is unnecessary'.</text>
# <proposer id="10514">Ross, William</proposer>
# <signature_count>1</signature_count>
# <signatures>
#   <signature>
#     <mp id="10514">Ross, William</mp>
#     <date>1997-03-19</date>
#     <type>Proposed</type>
#   </signature>
# </signatures>