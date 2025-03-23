require 'logger'

# Ensure Logger::Severity is available for Rails
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
