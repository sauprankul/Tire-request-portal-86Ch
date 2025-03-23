# Monkey patch to fix the Logger::Severity issue in Ruby 3.2 with Rails 7.0
require 'logger'

# Ensure the Logger class has the Severity module
unless defined?(::Logger::Severity)
  class ::Logger
    module Severity
      DEBUG = 0
      INFO = 1
      WARN = 2
      ERROR = 3
      FATAL = 4
      UNKNOWN = 5
    end
    include Severity
  end
end

# Ensure ActiveSupport can find Logger::Severity
module ActiveSupport
  module LoggerThreadSafeLevel
    # Only define this if it's not already defined
    unless const_defined?(:Logger)
      Logger = ::Logger
    end
  end
end
