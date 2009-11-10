class Edm < ActiveRecord::Base
  has_one :proposer
  has_and_belongs_to_many :signatories
end