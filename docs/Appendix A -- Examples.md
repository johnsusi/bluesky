# A. Examples


## Fetch data using REST and keep UI in sync

This example renders a list of people on the planet *Tatooine*. Data is supplied
by [The Starwars API](http://swapi.co/). Since this is *REST* several roundtrips
are needed to get all the residents. Dispatch ensures that all requests are
done and the final callback invoked before calling refresh on the entire
application causing a render.

```ruby
require 'bluesky'
include Bluesky

require 'bowser/http'

module PersonStore
  include DOMHelper

  extend self

  def residents_of_tatooine
    Bowser::HTTP.fetch('http://swapi.co/api/planets/1/').then do |response|
      Promise.when(*response.json[:residents].map do |resident_uri|
        Bowser::HTTP.fetch(resident_uri).then do |resident|
          resident.json[:name]
        end
      end)
    end
  end

end

class Person < PureComponent
  attribute :name
  def render
    li [name]
  end
end

class PersonList < PureComponent
  attribute :persons
  def render
    ol persons.map { |person| Person(person) }
  end
end

class PersonController < ViewController
  attribute :names, []
  def view
    PersonList(persons: names)
  end
  def view_will_appear
    dispatch(PersonStore, :residents_of_tatooine).then do |residents|
      self.names = residents.map { |name| { name: name } }
    end
  end
end

$app = Class.new(Application) do
  def root_view_controller
    @root_view_controller ||= PersonController.new
  end
end.new

$app.debug!
$app.run
```