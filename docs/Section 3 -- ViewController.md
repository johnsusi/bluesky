# ViewController

ViewControllers are responsible for the UI logic in an application.
ViewControllers feed data into presentational components (`PureComponent`) and
respond to user interactions.

```ruby
class HelloController < ViewController

  attribute :name

  def view
    HelloView(name: name)
  end

  def change_name(name)
    self.name = name
  end
end
```

## View events

A `ViewController` gets notified when changes are made to its views visibility.

**view_will_appear**

Called before the views `render` method is called for the first time.

**view_did_appear**

Called after the first render is completed and the *DOM* has reconciled.

**view_will_disappear**

Called when the view is about to be removed from the render. *DOM* nodes are
still mounted.

**view_did_disappear**

Called when the view has been removed from the render and the *DOM* has
reconciled. All previously mounted *DOM* nodes have been unmounted.

NOTE: DOM nodes may still be reused for other views so make sure you have
      cleaned up after yourself.

## Standard dispatch methods

A `ViewController` supports the following dispatch methods out of the box.

There is a more complete description of the dispatch mechanism in Section 5.

**refresh**

Triggers a rerendering of the entire application. Caching still applies and
refresh should rarely be of any use.

**force_update**

Triggers a force rerendering of the application and disables caching for the
ViewControllers view. This could be used when something changed outside of your
views that the views depend on. For example changing language in the app.

## NavigationController

`NavigationController` is modelled after the iOS `UINavigationController` and
fills a similar function in *Bluesky*.

`NavigationController` manages a stack of `ViewControllers` that can be pushed
and popped.

```ruby
class HelloController < ViewController
  # ...
end

class RootController < ViewController
  # ...
end

navigation_controller = NavigationController.new(RootController)

navigation_controller.push_view_controller(HelloController.new)

navigation_controller.pop_view_controller

```

All descendants of `ViewController` can access its nearest ancestor of type
`NavigationController` using the `navigation_controller` property.

```ruby
class HelloController < ViewController
  def back
    navigation_controller.pop_view_controller
  end
end
```