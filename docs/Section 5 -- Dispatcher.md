# Dispatcher

Dispatcher is the main tool for performing actions in *Bluesky*.

All dispatch requests (unless intercepted) go through the dispatch queue in
`Application`.

## Asynchrous by design

A dispatch request is never performed synchronously. Instead it has to pass
through the application dispatch queue where each request is executed in turn
and on the main event loop.

Dispatch *targets* are just objects and *actions* are just methods on those
objects.

```ruby
dispatch("hello", :upcase).then do |str|
  puts str # HELLO
end
```

Dispatcher plays an important part when separating views from controllers and
models. A view never need to know anything about the target of the dispatch
except an ubiquitous naming of the actions. In fact it is strongly recommended
to design a view with just a data object and a mock dispatcher. They should be
completely independent of any *controller* or *model*.

Dispatch always returns a promise that you can chain. At the end of each
dispatch chain there is a `refresh` attached so you do not have to worry about
keeping your UI refreshed.

Here is a larger example of a *Store* that might have to do asynchronous work
before returning a value. The dispatch client does not see any difference.

```ruby
module Store
  include DOMHelpers
  extend self

  def fetch(what)
    case what
    when :fruit
      [:apple, :orange, :banana].sample
    when :beverage
      delay(seconds: 3) { :milk }
    end
  end
end

dispatch(Store, :fetch, :fruit).then do |fruit|
  puts fruit
end

dispatch(Store, :fetch, :beverage).then do |beverage|
  puts beverage
end
```

Promises are easy to chain so multiple asynchronous requests can be made
before reaching the target.

## Blocks vs Promise

Dispatch returns a promise and thus can be chained using `.then` but sometimes
the dispatch target can take a block and this can lead to some confusion.

```ruby
module Store
  include DOMHelpers
  extend self

  def foo
    puts "foo #{block_given?}"
  end

  def bar
  end
end

dispatch(Store, :foo)                     # 'foo false'
dispatch(Store, :foo).then {}             # 'foo false'
dispatch(Store, :foo) {}                  # 'foo true'

dispatch(Store, :bar).then { puts 'bar' } # 'bar'
dispatch(Store, :bar) { puts 'bar' }      # <nothing>
```

The distinction here is important. If you supply a block by mistake when you
intended to chain the promise, the block will never be called, or worse if the
target action supports optional blocks, alter the dispatch result.

## Intercept dispatch requests

NOTE: This is an advanced topic not for everyday use

A `ViewController` may intercept any dispatch request traveling up the parent
hierarchy by implementing:

```ruby
def dispatch(target, action, *payload, &block)
end
```

It is possible to route or filter dispatch requests here by issuing a new
`dispatch`.

```ruby
def dispatch(target, action, *payload, &block)
  case target
  when :store
    # Route target to Store
    parent.dispatch(Store, action, *payload, &block)
  else
    # Otherwise send the dispatch up the chain
    parent.dispatch(target, action, *payload, &block)
  end
end
```

Note: You should always send your dispatch up the ancestor chain by calling
      dispatch on parent.