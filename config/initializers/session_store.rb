# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_parlytags_session',
  :secret      => 'da806929dfe2c7e4b9250f80f6ef3deac5b64da6ce795771c8429136ed06035558258f9deed2277b37fe39467ac3a67cfcd34b9955d5c53db4989420d766c710'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
