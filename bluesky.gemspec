%w(lib).each do |dir|
  path = File.expand_path(File.join('..', dir), __FILE__)
  $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
end

require 'bluesky/version'

Gem::Specification.new do |s|
  s.name        = 'bluesky'
  s.version     = Bluesky::VERSION
  s.date        = '2017-01-21'
  s.summary     = 'An app framework for Clearwater'
  s.description = 'An app framework built on top of opal and clearwater'
  s.authors     = ['John Susi']
  s.email       = 'john@susi.se'
  s.homepage    = 'https://johnsusi.github.com/bluesky/'
  s.license     = 'MIT'
  s.executables << 'bluesky'
  s.files       = [
    'lib/bluesky.rb',
    'lib/bluesky/application.rb',
    'lib/bluesky/dsl.rb',
    'lib/bluesky/helpers.rb',
    'lib/bluesky/navigation_controller.rb',
    'lib/bluesky/pure_component.rb',
    'lib/bluesky/version.rb',
    'lib/bluesky/view_controller.rb'
  ]
  s.test_files = [
    'test/test_helper.rb',
    'test/view_controller_test.rb',
    'test/navigation_controller_test.rb'
  ]
  s.require_paths = [
    File.expand_path(File.join('..', 'lib'), __FILE__)
  ]
  s.add_runtime_dependency 'opal', '~> 0.10'
  s.add_runtime_dependency 'clearwater', '1.0.0.rc4'
  s.add_development_dependency 'minitest', '~> 5.10'
end
