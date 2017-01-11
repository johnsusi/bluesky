%w(lib).each do |dir|
  path = File.expand_path(File.join('..', dir), __FILE__)
  $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
end

require 'bluesky/version'

Gem::Specification.new do |s|
  s.name        = 'bluesky'
  s.version     = Bluesky::VERSION
  s.date        = '2016-12-24'
  s.summary     = 'An app framework for Clearwater'
  s.description = 'An app framework for Clearwater'
  s.authors     = ['John Susi']
  s.email       = 'john@susi.se'
  s.homepage    = 'http://rubygems.org/gems/bluesky'
  s.license     = 'MIT'
  s.executables << 'bluesky'
  s.files       = [
    'lib/bluesky.rb',
    'lib/bluesky/application.rb',
    'lib/bluesky/dom_helper.rb',
    'lib/bluesky/navigation_controller.rb',
    'lib/bluesky/pure_component.rb',
    'lib/bluesky/try.rb',
    'lib/bluesky/version.rb',
    'lib/bluesky/view_controller.rb'
  ]
  s.test_files = [
    # 'spec/spec_helper.rb',
    # 'spec/view_controller_spec.rb'
  ]

  s.require_paths = [
    File.expand_path(File.join('..', 'lib'), __FILE__)
  ]

  s.add_runtime_dependency 'opal', '~> 0.10'
  s.add_runtime_dependency 'clearwater', '1.0.0.rc4'

  s.add_development_dependency 'minitest'
  s.add_development_dependency 'rake'
  # s.add_development_dependency 'opal-rspec'
  # s.add_development_dependency 'rspec', "~> 3.2"
  # s.add_development_dependency 'fuubar'

end
