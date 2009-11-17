class MemberSignature < ActiveRecord::Base
  belongs_to :edm
  belongs_to :signature
end