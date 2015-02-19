rails_spec = (Gem.loaded_specs["railties"] || Gem.loaded_specs["rails"])
version = rails_spec.version.to_s

if Gem::Version.new(version) < Gem::Version.new('4.1.0')
  puts "You are using an old version of Rails (#{version})"
  puts "Please update"
  puts "Stopping"
  exit 1
end

if yes?("Use Bootstrap?")
  bootstrap = true
end


remove_file 'Gemfile'
create_file 'Gemfile' do <<-TEXT
source 'https://rubygems.org'

ruby '2.1.5'
gem 'rails', '4.1.8'

# Mongo DB
gem 'moped'
gem 'mongoid'
gem 'mongoid-slug'

# Assets
gem 'uglifier'
gem 'autoprefixer-rails'
gem 'jquery-rails-cdn'
gem 'coffee-rails'
gem 'sass-rails'
gem 'compass-rails'

# Frontend
gem 'slim-rails'
gem 'evil-blocks-rails'
gem 'normalize-rails'
gem 'svg_rails', github: 'mustangostang/svg_rails'
gem 'rails_view_helpers', github: 'jimmyn/rails_view_helpers'
#{"gem 'bootstrap-sass'" if bootstrap}

# Business logic
gem 'therubyracer'
gem 'draper'
gem 'simple_form'
gem 'unicorn'
gem 'ffaker'
gem 'russian'
gem 'mini_magick'
gem 'carrierwave-mongoid'
gem 'mongoid_globalize', github: 'Infotaku/mongoid_globalize'
gem 'bson_ext'
gem 'fog'
gem 'devise'
gem 'devise-russian'
gem 'decent_exposure'

# Activeadmin
gem 'ransack', github: 'pencilcheck/ransack', branch: 'patch-1'
gem 'activeadmin', github: 'activeadmin'
gem 'activeadmin-mongoid', github: 'pencilcheck/activeadmin-mongoid', branch: 'patch-1'
gem 'activeadmin-settings', github: 'jimmyn/activeadmin-settings'
gem 'active_admin_theme', github: 'jimmyn/active_admin_theme'
gem 'activeadmin-extra', github: 'jimmyn/activeadmin-extra'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'letter_opener'
  gem 'capistrano', '~> 2'
  gem 'pry-rails'
end

TEXT
end

run 'bundle install'

generate "simple_form:install #{'--bootstrap' if bootstrap}"

generate "devise:install"
generate "active_admin:install"
generate "activeadmin_settings:install"

remove_file '.gitignore'
create_file '.gitignore' do <<-TEXT
# See https://help.github.com/articles/ignoring-files for more about ignoring files.
#
# If you find yourself ignoring temporary files generated by your text editor
# or operating system, you probably want to add a global ignore instead:
#   git config --global core.excludesfile '~/.gitignore_global'

/.bundle
/log/*.log
/tmp
/public/system
/public/uploads
/config/mongoid.yml
TEXT
end

create_file 'app/assets/javascripts/blocks/.gitkeep', ''

remove_file 'config/initializers/cookies_serializer.rb'
create_file 'config/initializers/cookies_serializer.rb' do  <<-TEXT
# Be sure to restart your server when you modify this file.
# json serializer breaks Devise + Mongoid. DO NOT ENABLE
# See https://github.com/plataformatec/devise/pull/2882
# Rails.application.config.action_dispatch.cookies_serializer = :json
Rails.application.config.action_dispatch.cookies_serializer = :marshal
TEXT
end

create_file 'config/mongoid.yml' do <<-TEXT
development:
  sessions:
    default:
      database: #{app_name.downcase}_development
      hosts:
          - localhost:27017
test:
  sessions:
    default:
      database: #{app_name.downcase}_test
      hosts:
          - localhost:27017
TEXT
end

remove_file 'config/application.rb'
create_file 'config/application.rb' do <<-TEXT
require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_model/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "active_job/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module #{app_name.camelize}
  class Application < Rails::Application
    config.generators do |g|
      g.view_specs false
      g.helper_specs false
      g.feature_specs false
      g.template_engine :slim
      g.stylesheets false
      g.javascripts false
      g.helper false
    end

    config.i18n.locale = :ru
    config.i18n.default_locale = :ru
    config.i18n.available_locales = [:ru, :en]
    config.i18n.enforce_available_locales = true
    config.time_zone = 'Europe/Moscow'
    config.assets.paths << Rails.root.join("app", "assets", "fonts")
  end
end

TEXT
end

remove_file 'public/robots.txt'
create_file 'public/robots.txt' do <<-TEXT
User-Agent: *
Disallow: /
TEXT
end

remove_file 'app/views/layouts/application.html.erb'
create_file 'app/views/layouts/application.html.slim' do <<-TEXT
doctype html
html
  head
    title #{app_name.capitalize}
    meta name="viewport" content="width=device-width, initial-scale=1.0"
    = stylesheet_link_tag    "application", media: 'all'
    = javascript_include_tag "application"
    = csrf_meta_tags

  body
    = yield
TEXT
end

if bootstrap
create_file 'app/assets/stylesheets/bootstrap_custom.sass' do <<-TEXT
// Core variables and mixins
@import bootstrap/variables
@import bootstrap/mixins

// Reset and dependencies
@import bootstrap/normalize
@import bootstrap/print
@import bootstrap/glyphicons

// Core CSS
@import bootstrap/scaffolding
@import bootstrap/type
@import bootstrap/code
@import bootstrap/grid
@import bootstrap/tables
@import bootstrap/forms
@import bootstrap/buttons

// Components
@import bootstrap/component-animations
@import bootstrap/dropdowns
@import bootstrap/button-groups
@import bootstrap/input-groups
@import bootstrap/navs
@import bootstrap/navbar
@import bootstrap/breadcrumbs
@import bootstrap/pagination
@import bootstrap/pager
@import bootstrap/labels
@import bootstrap/badges
@import bootstrap/jumbotron
@import bootstrap/thumbnails
@import bootstrap/alerts
@import bootstrap/progress-bars
@import bootstrap/media
@import bootstrap/list-group
@import bootstrap/panels
@import bootstrap/responsive-embed
@import bootstrap/wells
@import bootstrap/close

// Components w/ JavaScript
@import bootstrap/modals
@import bootstrap/tooltip
@import bootstrap/popovers
@import bootstrap/carousel

// Utility classes
@import bootstrap/utilities
@import bootstrap/responsive-utilities
TEXT
end

create_file 'app/assets/javascripts/bootstrap_custom.js.coffee' do <<-TEXT
#= require bootstrap/affix
#= require bootstrap/alert
#= require bootstrap/button
#= require bootstrap/carousel
#= require bootstrap/collapse
#= require bootstrap/dropdown
#= require bootstrap/modal
#= require bootstrap/popover
#= require bootstrap/scrollspy
#= require bootstrap/tab
#= require bootstrap/tooltip
#= require bootstrap/transition
TEXT
end
end

remove_file 'app/assets/stylesheets/application.css'
create_file 'app/assets/stylesheets/application.css.sass' do <<-TEXT
@import normalize-rails
@import compass
@import bootstrap_custom
TEXT
end

remove_file 'app/assets/javascripts/application.js'
create_file 'app/assets/javascripts/application.js.coffee' do <<-TEXT
#= require jquery
#= require jquery_ujs
#= require evil-blocks
#= require bootstrap_custom
#= require_tree ./blocks

TEXT
end

remove_file 'app/assets/stylesheets/active_admin.css.scss'
create_file 'app/assets/stylesheets/active_admin.css.sass' do <<-TEXT
@import active_admin/mixins
@import active_admin/base
@import active_admin/extra
@import activeadmin_settings
@import active_admin_theme

TEXT
end

remove_file 'app/assets/javascripts/active_admin.js.coffee'
create_file 'app/assets/javascripts/active_admin.js.coffee' do <<-TEXT
#= require active_admin/base
#= require active_admin/extra
#= require activeadmin_settings
#= require_self

window.redactor_settings = {lang: 'ru'}

TEXT
end

remove_file 'db/seeds.rb'
create_file 'db/seeds.rb' do <<-TEXT
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if AdminUser.count == 0

require 'ffaker'

TEXT
end

FileUtils.cp(Pathname.new(destination_root).join('config', 'mongoid.yml').to_s, Pathname.new(destination_root).join('config', 'mongoid.yml.example').to_s)

rake 'db:seed'
generate :controller, 'pages index'
route "root to: 'pages#index'"
run "rm public/index.html"

after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end

