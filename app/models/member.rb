class Member < ActiveRecord::Base
  
  has_friendly_id :display_name, :use_slug => true, :strip_diacritics => true
  
  has_many :proposers
  has_many :seconders
  has_many :signatories
  
  def edms_proposed session_id=nil
    if session_id
      session_proposers = Proposer.find_all_by_member_id_and_session_id(id, session_id)
      session_proposers.collect { |x| x.edm }
    else
      proposers.collect { |x| x.edm }
    end
  end
  
  def edms_signed session_id=nil
    if session_id
      session_signatories = Signatory.find_all_by_member_id_and_session_id(id, session_id)
      session_signatories.collect { |x| x.edm }
    else
      signatories.collect { |x| x.edm }
    end
  end
  
  def edms_seconded session_id=nil
    if session_id
      session_seconders = Seconder.find_all_by_member_id_and_session_id(id, session_id)
      session_seconders.collect { |x| x.edm }
    else
      seconders.collect { |x| x.edm }
    end
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