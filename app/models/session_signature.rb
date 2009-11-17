class SessionSignature < ActiveRecord::Base
  belongs_to :session
  belongs_to :signature
end