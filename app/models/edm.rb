class Edm < ActiveRecord::Base
  has_many :motion_signatures
  has_many :proposers, :through => :motion_signatures, :source => :signature, :conditions => "type = 'Proposer'"
  has_many :seconders, :through => :motion_signatures, :source => :signature, :conditions => "type = 'Seconder'"
  has_many :signatories, :through => :motion_signatures, :source => :signature, :conditions => "type = 'Signatory'"
  belongs_to :session
  has_many :edm_amendments
  
  delegate :name, :to => :session, :prefix => :session
  
  def signatories_and_seconders_count
    signatories.size + seconders.size
  end
  
  def seconders_count
    seconders.size
  end
  
  def has_proposer?
    proposers.size > 0
  end
  
  def is_amendment?
    amendment_format = /\d+A\d+/
    if number =~ amendment_format
      true
    else
      false
    end
  end
  
  def has_amendments?
    edm_amendments.size > 0
  end
  
  def edm_amended
    amendment_format = /(\d+)A\d+/
    if number =~ amendment_format
      return Edm.find_by_number_and_session_id($1, session_id)
    end
    nil
  end
  
end