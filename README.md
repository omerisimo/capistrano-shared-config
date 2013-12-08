capistrano-shared-config
========================

Capistrano tasks for managing configuration files for different servers/environments using templates.

Create customized configuration files per environment in the application's `shared` directory, and symlink the files into the current release `config` directory.

Provides tasks for:

* Creating configuration files in the `shared` directory according to predefined templates.
* Symlink the files into the current release `config` directory at deploy time.

## Installation

Add this line to your application's Gemfile:

```ruby
group :development do
	gem 'capistrano-shared-conifg', require: false, git: "git://github.com/omerisimo/capistrano-shared-config.git"
end
```

And then execute:

```sh
bundle
```

## Usage

Add this line to your `deploy.rb`

```ruby
require 'capistrano-shared-config'
```

You can check that new tasks are available (`cap -T`).

###Configuration file templates

Create new directory

```sh
$ mkdir <PROJECT_DIRECTORY>/config/deploy/templates
```	

Add your configuration file to that folder with an `.erb` extension

```sh
$ touch <PROJECT_DIRECTORY>/config/deploy/templates/database.yml.erb
```	

Replace the configuration values with ruby variables

```yml
# ./config/deploy/templates/database.yml.erb
<%= env %>: # e.g. staging
  adapter: postgresql
  encoding: unicode
  database: <%= database_name %>
  username: <%= deploy_user %>
  password: <%= database_password %>
```

**Note:** You can change the template files directory by setting `:config_template_path`:

```ruby
set :config_template_path, "/some/other/directory"
```

###In `deploy.rb`

Set the names of your configuration files.

```ruby
set :shared_config_files, %w(database.yml)
```

Set the variables names as required by the `.erb` template.

```ruby
set :env, "staging"
set :database_name, "my_db_name"
set :deploy_user, "deploy"
set :database_password, "my_db_password" # You really shouldn't commit that to your repository
```

### Tasks

#### shared_config:setup
After setting up your configuration templates and Capistrano variables in `deploy.rb` run the setup task:

```sh
cap shared_config:setup
```

The task will create a `/config` directory under Capistrano's `:shared_path` directory.
In that directory you will find the new configuration file:

```yml
# <APPLICATION_FOLDER>/shared/config/database.yml
staging:
  adapter: postgresql
  encoding: unicode
  database: my_db_name
  username: deploy
  password: my_db_password
```

**Note:** You can change the path of shared config files directory by setting `:shared_config_path`:

``` ruby
set :shared_config_path, "<APPLICATION_FOLDER>/shared/other_directory"
```

**Hint:** it can be a good idea to hook the `shared_config:setup` after the `deploy:setup` task:

``` ruby
after "deploy:setup", "shared_config:setup"
```

#### shared_config:symlink_files

The `shared_config:symlink_files` task is hooked after `deploy:finalize_update` task, and will run at each deploy.
It will symlink the files from your `:shared_config_path` directory to the application's `config` directory.

## License

See LICENSE file for details.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Run the tests (`bundle exec rake`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
