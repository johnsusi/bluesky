require 'minitest/autorun'
require 'bluesky/view_controller'
require 'bluesky/navigation_controller'

class MockApplication < Bluesky::ViewController

  def refresh
    yield if block_given?
  end

  def force_update
    yield if block_given?
  end

end

class Bluesky::ViewController

  def index
    @index ||= 0
    @index += 1
  end

  def view_will_appear
    @will_appear = index
  end

  def view_did_appear
    @did_appear = index
  end

  def view_will_disappear
    @will_disappear = index
  end

  def view_did_disappear
    @did_disappear = index
  end

  def appeared?
    !!(@will_appear && @did_appear && @will_appear < @did_appear &&
      (@will_disappear ? @will_appear > @will_disappear : true) &&
      (@did_disappear  ? @did_appear > @did_disappear : true))
  end

  def disappeared?
    !!(@will_disappear && @did_disappear && @will_disappear < @did_disappear &&
      (@will_appear ? @will_disappear > @will_appear : true) &&
      (@did_appear  ? @did_disappear > @did_appear : true))
  end

  def reset!
    @will_appear = @did_appear = @will_disappear = @did_disappear = false
    @index = 0
  end

  def dump
    puts "will_appear == #{@will_appear}"
    puts "did_appear == #{@did_appear}"
    puts "will_disappear == #{@will_disappear}"
    puts "did_disappear == #{@did_disappear}"
  end

end

class Bluesky::NavigationController
  def self.new *args
    instance = super
    instance.parent = MockApplication.new
    instance
  end
end

