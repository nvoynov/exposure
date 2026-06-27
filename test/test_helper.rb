# test/test_helper.rb
# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'minitest/autorun'
require 'minitest/pride' # Colored output
require 'exposure'       # Main entry point loading the library

