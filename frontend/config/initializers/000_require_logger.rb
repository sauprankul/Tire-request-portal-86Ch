# This initializer loads before all others to ensure the logger is available
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

# Explicitly require the logger and ensure Logger::Severity is defined
# Make sure the Severity module is defined
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

# Ensure the constants are defined
Logger::Severity.constants.each do |severity|
  puts "Logger::Severity::#{severity} is defined and equals #{Logger::Severity.const_get(severity)}"
end
