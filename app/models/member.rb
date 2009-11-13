class Member < ActiveRecord::Base
  has_many :proposers
  has_many :seconders
  has_many :signatories
  
  def edms_proposed
    proposers
  end
  
  def edms_signed
    signatories
  end
  
  def edms_seconded
    seconders
  end
  
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