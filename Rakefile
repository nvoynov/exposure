# Rakefile
# Custom tasks inside rakelib/*.rake are loaded automatically by Rake engine
# frozen_string_literal: true

# require 'rake/testtask'

# Rake::TestTask.new(:test) do |t|
#   t.libs << 'test'
#   t.pattern = 'test/**/*_test.rb'
#   t.verbose = false
# end

# frozen_string_literal: true

# require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create

task default: :test
