# frozen_string_literal: true

Rack::Timeout.timeout = ENV.fetch('REQUEST_TIMEOUT') { 60 }.to_i
