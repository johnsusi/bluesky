# Application


```ruby
$app = Class.new(Bluesky::Application) do

  def root_view_controller
    @root_view_controller ||= NavigationController.new(LayoutController.new)
  end

end.new

$app.debug!
$app.run
```

## Application delegate

`Application` supports adding a delegate to get notified of different actions.

```ruby
class ApplicationDelegate

  def dispatch(target, actions, *payload)
  end

  def dispatch_resolved(target, actions, *payload, result)
  end

  def dispatch_rejected(error, target, actions, *payload)
  end

end
```

**dispatch**

Called when Adding a dispatch request to the dispatch queue.

**dispatch_resolved**

Called when the dispatch request has been performed.



