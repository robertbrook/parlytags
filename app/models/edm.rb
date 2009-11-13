class Edm < ActiveRecord::Base
  has_many :member_signatures
  has_many :proposers, :through => :member_signatures, :source => :signature, :conditions => "type = 'Proposer'"
  has_many :seconders, :through => :member_signatures, :source => :signature, :conditions => "type = 'Seconder'"
  has_many :signatories, :through => :member_signatures, :source => :signature, :conditions => "type = 'Signatory'"
  
  def signatories_and_seconders_count
    signatories.size + seconders.size
  end
  
  def seconders_count
    seconders.size
  end
end