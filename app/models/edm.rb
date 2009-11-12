class Edm < ActiveRecord::Base
  has_many :member_signatures
  has_many :proposers, :through => :member_signatures, :source => :signature, :source_type => 'Proposer'
  has_many :seconders, :through => :member_signatures, :source => :signature, :source_type => 'Seconder'
  has_many :signatories, :through => :member_signatures, :source => :signature, :source_type => 'Signatory'
  
  def signatories_and_seconders_count
    signatories.count + seconders.count
  end
  
  def seconders_count
    seconders.count
  end
end