module Capistrano
  module SharedConfig
    unless defined?(::Capistrano::SharedConfig::VERSION)
      VERSION = "0.0.1".freeze
    end
  end
end
