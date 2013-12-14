require 'spec_helper'

describe Capistrano::SharedConfig::Tasks do
  before do
    @configuration = Capistrano::Configuration.new
    @configuration.extend(Capistrano::Spec::ConfigurationExtension)
    @configuration.set(:shared_path, "./shared")
    @configuration.set(:release_path, "./current_release")
  end

  subject do
    Capistrano::SharedConfig::Tasks.load_into(@configuration)
    @configuration
  end

  context "loaded into configuration" do
    describe "hooks" do
      before do
        @configuration.stub(:after)
      end

      specify "shared_config:symlink_files after deploy:finalize_update" do
        @configuration.should_receive(:after).with("deploy:finalize_update", "shared_config:symlink_files")
        Capistrano::SharedConfig::Tasks.load_into(@configuration)
      end
    end

    describe "sets default values to" do
      before do
        @configuration.stub(:set)
      end

      specify "shared_config_path" do
        @configuration.should_receive(:set).with(:shared_config_path) do |&block|
          block.call.should == "#{@configuration.shared_path}/config"
        end
        Capistrano::SharedConfig::Tasks.load_into(@configuration)
      end

      specify "config_template_path" do
        @configuration.should_receive(:set).with(:config_template_path, "./config/deploy/templates")
        Capistrano::SharedConfig::Tasks.load_into(@configuration)
      end

      specify "shared_config_files" do
        @configuration.should_receive(:set).with(:shared_config_files, [])
        Capistrano::SharedConfig::Tasks.load_into(@configuration)
      end
    end
  end

  describe "task" do
    before do
      subject.set(:shared_config_files, %w{database.yml settings.yml})
    end
    describe "shared_config:setup" do
      before do
        File.stub(:read).and_return("configuration file ERB template")
        @template = double("template")
        ERB.stub(:new).and_return(@template)
        @template.stub(:result).and_return("evaluated file")
      end

      it "creates a config directory for :shared_config_path" do
        subject.find_and_execute_task("shared_config:setup")

        subject.should have_run("mkdir -p #{subject.shared_config_path}")
      end
      
      it "reads each of templates files defined by :shared_config_files" do
        File.should_receive(:read).with("#{subject.config_template_path}/database.yml.erb")
        File.should_receive(:read).with("#{subject.config_template_path}/settings.yml.erb")

        subject.find_and_execute_task("shared_config:setup")
      end

      it "evaluates the config file templates with ERB" do
        ERB.should_receive(:new).with("configuration file ERB template").twice.and_return(@template)

        subject.find_and_execute_task("shared_config:setup")
      end

      it "puts the evaluated config file in the :shared_config_path" do
        subject.find_and_execute_task("shared_config:setup")

        subject.should have_put("evaluated file").to("#{subject.shared_config_path}/database.yml")
        subject.should have_put("evaluated file").to("#{subject.shared_config_path}/settings.yml")
      end
    end

    describe "shared_config:symlink_files" do
      it "runs a symlink command for each of the files defined by :shared_config_files" do
        subject.find_and_execute_task("shared_config:symlink_files")

        subject.should have_run("ln -nfs #{subject.shared_config_path}/database.yml #{subject.release_path}/config/database.yml")
        subject.should have_run("ln -nfs #{subject.shared_config_path}/settings.yml #{subject.release_path}/config/settings.yml")
      end
    end
  end

  describe  "#shared_config_roles_filter" do
    context "with default options" do
      it "returns the default roles filter options" do
        subject.shared_config_roles_filter.should == {
          roles: :app,
          only: {},
          on_no_matching_servers: :continue
        }
      end
    end

    context "with custom options" do
      it "returns the custom roles filter options" do
        subject.set(:shared_config_roles, [:role1, :role2])
        subject.set(:shared_config_roles_options, {option1: :value1})
        subject.shared_config_roles_filter.should == {
          roles: [:role1, :role2],
          only: {option1: :value1},
          on_no_matching_servers: :continue
        }
      end
    end
  end
end