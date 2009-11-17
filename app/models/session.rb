class Session < ActiveRecord::Base
  has_many :edms
  
  has_many :session_signatures
  has_many :proposers, :through => :session_signatures, :source => :signature, :conditions => "type = 'Proposer'"
  has_many :seconders, :through => :session_signatures, :source => :signature, :conditions => "type = 'Seconder'"
  has_many :signatories, :through => :session_signatures, :source => :signature, :conditions => "type = 'Signatory'"
end