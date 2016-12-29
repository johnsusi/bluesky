require 'bundler'
Bundler.require

# Instructions: bundle in this directory
# then run bundle exec rackup to start the server
# and browse to localhost:9292

run Opal::Server.new { |s|
  s.main = 'application'
  s.append_path '.'
  s.index_path = 'index.html.erb'
}