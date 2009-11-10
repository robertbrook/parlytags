class Signatory < ActiveRecord::Base
  has_and_belongs_to_many :edms
end
