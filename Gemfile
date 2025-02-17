source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '6.0.4.1'

gem 'sass-rails', '~> 5.0'
#gem 'coffee-rails', '~> 4.1.0'
#gem 'uglifier', '>= 4.2.0'
gem 'terser', '~> 1.1', '>= 1.1.1'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
# gem 'duktape'

gem 'bootstrap', '~> 4.2.0'
gem 'chart-js-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'select2-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# To use debugger
# gem 'debugger'

gem 'cube-ruby', require: 'cube'
gem 'dalli'
gem 'flamegraph'
gem 'haml', '~> 5.1'
gem 'i18n'
gem 'iconv'
gem 'multi_json'
gem 'mysql2', '0.5.2'
gem 'oj'
gem 'open_uri_redirections'
gem 'psych', '< 4'
gem 'pry'
gem 'rack-mini-profiler'
gem 'rails_autolink'
gem 'rdoc'
gem 'recaptcha', '~> 5.2'
gem 'rest-client'
gem 'stackprof', require: false
gem 'thin'
gem 'turnout'
gem 'will_paginate', '~> 3.0'

gem 'ontologies_api_client', git: 'https://github.com/ontoportal-lirmm/ontologies_api_ruby_client.git'


group :staging, :production do
  # application monitoring
  gem 'newrelic_rpm'
  # logs in json format, useful for shipping logs to logstash
  # gem 'rackstash', git: 'https://github.com/planio-gmbh/rackstash.git'
  # gem 'logstash-logger'
end

group :development do
  gem 'capistrano', '~> 3.11', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-locally', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-rails', '~> 1.4', require: false
  gem 'capistrano-yarn', require: false
  gem 'html2haml'
  gem 'listen'
  # static code analysis
  gem 'brakeman', require: false
  gem 'rubocop', require: false
  # gem 'i18n-debug'
end

group :test, :development do
  gem 'rspec-rails'
end

group :test do
  gem 'capybara'
end