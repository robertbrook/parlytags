class Signature < ActiveRecord::Base
  belongs_to :edm
  belongs_to :motion_signature, :polymorphic => true
  belongs_to :session_signature, :polymorphic => true
  belongs_to :member
end
