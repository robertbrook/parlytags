class Signature < ActiveRecord::Base
  has_and_belongs_to_many :edms
  belongs_to :member_signature, :polymorphic => true
  belongs_to :member
end
