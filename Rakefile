# require 'opal/rspec/rake_task'

# require 'clearwater'
# require '../lib/bluesky.rb'

# Opal.append_path File.expand_path('../spec', __FILE__)

# Opal::RSpec::RakeTask.new(:spec) do |server, task|
#   server.append_path 'lib'
#   task.files = FileList['spec/**/navigation_controller_spec.rb']
# end

# task :default => [:spec]

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.libs.push "test"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
  t.warning = false
end