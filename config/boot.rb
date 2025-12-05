ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.

# --- ADD THESE LINES TO FIX RUBY 3.4 COMPATIBILITY ---
require 'logger'
require 'mutex_m'
# -----------------------------------------------------
