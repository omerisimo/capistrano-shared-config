require 'capistrano'
require 'capistrano/cli'
require 'capistrano/version'

module Capistrano
  module SharedConfig
    class Tasks
      def self.load_into(capistrano_config)
        Capistrano::SharedConfig::Tasks.declare_variables capistrano_config
        Capistrano::SharedConfig::Tasks.declare_tasks capistrano_config
        Capistrano::SharedConfig::Tasks.declare_methods capistrano_config
      end

      private

      def self.declare_variables(capistrano_config)
        capistrano_config.load do
          set(:shared_config_path) { File.join(shared_path, "config") } unless exists?(:shared_config_path)
          set :config_template_path, "./config/deploy/templates" unless exists?(:config_template_path)
          set :shared_config_files, [] unless exists?(:shared_config_files)
        end
      end

      def self.declare_tasks(capistrano_config)
        Capistrano::SharedConfig::Tasks.declare_task_setup capistrano_config
        Capistrano::SharedConfig::Tasks.declare_task_symlink_files capistrano_config
      end

      def self.declare_task_setup(capistrano_config)
        capistrano_config.load do
          namespace :shared_config do
            desc 'Create and copy configuration files to the shared/config directory'
            task :setup do
              run "mkdir -p #{shared_config_path}", shared_config_roles_filter
              shared_config_files.each do |file|
                put ERB.new(File.read("#{config_template_path}/#{file}.erb")).result(binding), "#{shared_config_path}/#{file}", shared_config_roles_filter
              end
            end
          end
        end
      end

      def self.declare_task_symlink_files(capistrano_config)
        capistrano_config.load do
          namespace :shared_config do
            desc 'Symlink the configuration files in shared/config to the current/config directory'
            task :symlink_files do
              shared_config_files.each do |file|
                run "ln -nfs #{File.join(shared_config_path, file)} #{File.join(release_path, "config", file)}", shared_config_roles_filter
              end
            end
            after "deploy:finalize_update", "shared_config:symlink_files"
          end
        end
      end

      def self.declare_methods(capistrano_config)
        capistrano_config.load do
          def shared_config_roles_filter
            {
              roles: fetch(:shared_config_roles, :app),
              only: fetch(:shared_config_roles_options, {}),
              on_no_matching_servers: :continue
            }
          end
        end
      end
    end
  end
end


Capistrano::SharedConfig::Tasks.load_into(Capistrano::Configuration.instance) if Capistrano::Configuration.instance
