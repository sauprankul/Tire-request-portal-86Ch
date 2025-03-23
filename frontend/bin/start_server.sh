#!/bin/bash
# Ensure logger is loaded before Rails starts
require 'logger'

# Start the Rails server
bundle exec rails server -b 0.0.0.0
