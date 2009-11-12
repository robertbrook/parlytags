class Signature < ActiveRecord::Base
  belongs_to :edm
  belongs_to :member_signature, :polymorphic => true
  belongs_to :member
end
