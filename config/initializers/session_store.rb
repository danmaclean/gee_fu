# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_rbrowser_session',
  :secret      => '99e0810c53b29216d493c2bde8faf69aea53559e6c06a545f917f6813270d73fb5605168577e5462e1b9880edc16a9c4cfd962c01609d9516d921fadd56d5934'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
