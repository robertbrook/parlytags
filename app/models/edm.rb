class Edm < ActiveRecord::Base
  has_many :motion_signatures
  has_many :proposers, :through => :motion_signatures, :source => :signature, :conditions => "type = 'Proposer'"
  has_many :seconders, :through => :motion_signatures, :source => :signature, :conditions => "type = 'Seconder'"
  has_many :signatories, :through => :motion_signatures, :source => :signature, :conditions => "type = 'Signatory'"
  belongs_to :session
  has_many :edm_amendments
  
  delegate :name, :to => :session, :prefix => :session
  
  acts_as_tree :order => "amendment_number"
  is_taggable :tags
  
  class << self
    def amendment_format
      /(\d+)A(\d+)/
    end
  end
  
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
    if number =~ Edm.amendment_format
      true
    else
      false
    end
  end
    
end