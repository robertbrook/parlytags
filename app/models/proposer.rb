class Proposer < ActiveRecord::Base
  belongs_to :edm
  
  def display_name
    first_name = ""
    surname = ""
    if name[/, (.*)/]
      first_name = $1
    end
    if name[/^(.*),/]
      surname = $1
    end
    "#{first_name} #{surname}"
  end
    
end