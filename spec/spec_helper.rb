require 'coveralls'
Coveralls.wear!

require 'capistrano'
require 'capistrano-spec'
require 'capistrano-shared-config'

RSpec.configure do |config|
  config.include Capistrano::Spec::Matchers
  config.include Capistrano::Spec::Helpers
end
