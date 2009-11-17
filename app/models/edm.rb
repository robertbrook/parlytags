class Edm < ActiveRecord::Base
  has_many :motion_signatures
  has_many :proposers, :through => :motion_signatures, :source => :signature, :conditions => "type = 'Proposer'"
  has_many :seconders, :through => :motion_signatures, :source => :signature, :conditions => "type = 'Seconder'"
  has_many :signatories, :through => :motion_signatures, :source => :signature, :conditions => "type = 'Signatory'"
  belongs_to :session
  
  def signatories_and_seconders_count
    signatories.size + seconders.size
  end
  
  def seconders_count
    seconders.size
  end
end