# Getting started

Install *Bluesky* using

```
gem install bluesky
```

or using *Bundler*

```ruby
# Gemfile
source 'https://rubygems.org'

gem 'rack'
gem 'opal-sprockets'
gem 'bluesky'
```

Then create a `index.html.erb` file

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Bluesky</title>
  </head>
  <body>
    <%= javascript_include_tag 'application' %>
  </body>
</html>
```

and a `config.ru` file

```ruby
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
```

Finally create an `application.rb` containing

```ruby
require 'bluesky'
include Bluesky

class HelloView < PureComponent

  attribute :name

  def render
    div [h1("Hello #{name}"), name_input]
  end

  def name_input
    handler = -> (event) { dispatch(:change_name, event.target.value) }
    label ['Change name: ', input({ type:    'text',
                                    value:   name,
                                    oninput: handler })]
  end

end

class HelloController < ViewController

  attribute :name, 'World'

  def view
    HelloView(name: name)
  end

  def change_name(name)
    self.name = name
  end

end


$app = Class.new(Application) do
  def root_view_controller
    @root_view_controller ||= HelloController.new
  end
end.new

$app.debug!
$app.run
```
