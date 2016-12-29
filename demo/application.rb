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

  def foo
    puts "foo #{block_given?}"
  end

  def bar
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
    dispatch(PersonStore, :bar).then do
      puts 'bar done'
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
