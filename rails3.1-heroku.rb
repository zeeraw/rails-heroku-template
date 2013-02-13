def put_header header
  puts "-----------------------------------------------------------------------"
  puts header
  puts "-----------------------------------------------------------------------"
end

put_header "Rails Application Template for Heroku Cedar"
app_name = ask("What do you want to call your Heroku app?")

put_header "Remove unneeded files"
run 'rm public/index.html'
run 'rm app/assets/images/rails.png'
run 'rm README'
run 'touch README'

put_header "Create Gemfile"
run 'rm Gemfile'
create_file 'Gemfile', <<HERE
source 'http://rubygems.org'
gem 'rails', '3.2.11'
gem 'thin'
gem 'pg'
gem 'jquery-rails'
gem 'friendly_id', '4.0.9'

group :assets do
  gem 'less-rails', '2.2.6'
  gem 'uglifier', '1.3.0'
end
HERE

put_header "Create Procfile"
create_file 'Procfile', "web: bundle exec rails server thin -p $PORT"

put_header "Create database config"
run 'rm config/database.yml'
create_file 'config/database.yml', <<HERE
development:
  adapter: postgresql
  database: #{app_name}_development
  host: localhost
  encoding: utf8

test:
  adapter: postgresql
  database: #{app_name}_test
  host: localhost
  encoding: utf8
HERE

put_header "Setup Pow"
create_file '.powrc', <<HERE
if [ -f "$rvm_path/scripts/rvm" ] && [ -f ".rvmrc" ]; then
  source "$rvm_path/scripts/rvm"
  source ".rvmrc"
fi
HERE

create_file '.rvmrc', <<HERE
rvm 1.9.3@#{app_name}
HERE

put_header "Install bundles"
run "cd #{destination_root}"
run "rvm gemset create '#{app_name}'"
run "gem install bundler"
run "bundle install"

run "ln -s #{destination_root} ~/.pow/#{app_name}"

put_header "Setup database"
rake "db:create"

put_header "Get Skeleton"
run "cd app/assets/stylesheets"
run "curl https://raw.github.com/dhgamache/Skeleton/master/stylesheets/base.css -o app/assets/stylesheets/base.css"
run "curl https://raw.github.com/dhgamache/Skeleton/master/stylesheets/layout.css -o app/assets/stylesheets/layout.css"
run "curl https://raw.github.com/dhgamache/Skeleton/master/stylesheets/skeleton.css -o app/assets/stylesheets/skeleton.css"

put_header "Commit to git"
append_file '.gitignore' do
  '.DS_Store'
end
git :init
git :add => '.'
git :commit => "-m 'Initial commit of Rails app for Heroku Cedar'"

put_header "Create Heroku app"
run "heroku create #{app_name} --stack cedar --region eu"

put_header "Push to Heroku"
run "git push heroku master"
