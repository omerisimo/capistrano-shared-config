# -*- encoding: utf-8 -*-
require File.expand_path('../lib/capistrano/shared_config/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = 'capistrano-shared-config'
  gem.version     = Capistrano::SharedConfig::VERSION.dup
  gem.author      = 'Omer Gazit'
  gem.email       = 'omer.misc@gmail.com'
  gem.homepage    = 'https://github.com/omerisimo/capistrano-shared-config'
  gem.summary     = %q{Manage your application configuration in the Capistrano shared directory}
  gem.description = %q{Capistrano plugin to manage multiple servers/environments configuration in the Capistrano shared directory}

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rake'
  
  gem.add_runtime_dependency 'capistrano', '~>2'
end