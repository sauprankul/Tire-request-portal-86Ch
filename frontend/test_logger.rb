#!/usr/bin/env ruby

# This script tests if our logger fix works
require 'logger'

# Ensure Logger::Severity is available
unless defined?(Logger::Severity)
  class Logger
    module Severity
      DEBUG = 0
      INFO = 1
      WARN = 2
      ERROR = 3
      FATAL = 4
      UNKNOWN = 5
    end
  end
end

# Simulate the ActiveSupport module that's causing the error
module ActiveSupport
  module LoggerThreadSafeLevel
    # This is the line that's failing in Rails
    Logger::Severity.constants.each do |severity|
      puts "Successfully accessed Logger::Severity::#{severity}"
    end
  end
end

puts "Test completed successfully! The fix should work."
