class Member < ActiveRecord::Base
  
  has_friendly_id :display_name, :use_slug => true, :strip_diacritics => true
  
  has_many :proposers
  has_many :seconders
  has_many :signatories
  
  def edms_proposed
    proposers.collect { |x| x.edm }
  end
  
  def edms_signed
    signatories.collect { |x| x.edm }
  end
  
  def edms_seconded
    seconders.collect { |x| x.edm }
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