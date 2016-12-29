# PureComponent

Views or presentational components are what the user will see and interact with.
Views are built using *Clearwater* tags (h1, div, ...), composites (could be
plain functions) and `PureComponents` where `PureComponents` are the most
powerful of them all.

## Motivating example

```ruby
require 'bluesky'
include Bluesky

class HelloView < PureComponent
  attribute :name, 'World'
  def render
    h1 ["Hello #{name}"]
  end
end

class HelloController < ViewController

  def view
    HelloView()
  end

end

Class.new(Application) do
  def root_view_controller
    @root_view_controller ||= HelloController.new
  end
end.new.run
```

## Extended DSL

*Bluesky* uses *Clearwater* for rendering so all tags in *Clearwater* are
available by default. *Bluesky* also extends the DSL with Builders.

```ruby
def render
  form do |form|
    form << div do |div|
      div << label do |label|
        label.for = 'emailField'
        label << 'Email address'
      end
      div << input do |input|
        input.type        = :email
        input.id          = 'emailField'
        input.class       = 'form-control'
        input.placeholder = "Enter emailHelp"
      end
    end
  end
end
```

## Custom DSL

Build custom modules

```ruby
module CustomDSL

  include Bluesky::DSL # Optional, but gives access to h1, div and all PureComponents

  def Button(text)
    button({ onclick: -> (event) { yield event if block_given? } }, [text])
  end

  def LabelInput(name, label, type)
    handler = -> (event) { dispatch(:form_change, event.target.name, event.target.value)}
    label({ for: name }, [label, input({ name: name,
                                         type: type,
                                         oninput: handler,
                                         onchange: handler })])
  end
end

class CustomComponent < PureComponent

  include CustomDSL

  def render
    div [ Button("hello") { puts 'hello' },
          LabelInput('name', 'Change name', :text) { |name| puts name } ]
  end

end
```

Extend the *Bluesky* DSL.

```ruby
module Bluesky
  module DSL
    def textarea(attributes = {}, contents = nil)
      attributes[:class] = "form-control"
      tag('textarea', attributes, contents)
    end
  end
end
```

## Dispatching

```ruby
require 'bluesky'
include Bluesky

class HelloView < PureComponent

  attribute :name

  def render
    div [title, name_input]
  end

  def title
    h1 ["Hello #{name}"]
  end

  def name_input
    label [
      'Your name: ',
      input({ type: 'text', value: name, oninput: -> (event) {
        dispatch(:change_name, event.target.value)
      }})
    ]
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

Class.new(Application) do
  def root_view_controller
    @root_view_controller ||= HelloController.new
  end
end.new.run

```

Note: In a `PureComponent` the dispatch target is fixed to `@delegate`. While it
      is possible to call `@delegate.dispatch(target, action, ...)` it is not
      recommended. Tying your view to a dispatch target is bad design.

## Caching
