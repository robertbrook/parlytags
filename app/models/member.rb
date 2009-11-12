class Member < ActiveRecord::Base
  
  def display_name
    first_part = ""
    surname = ""

    if name[/, (.*)/]
      first_part = $1
    end

    if name[/^(.*),/]
      surname = $1
    end

    "#{first_part} #{surname}"
  end
end