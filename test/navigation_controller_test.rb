require 'test_helper'

class TestNavigationController < Minitest::Test

  include Bluesky

  def test_appearing_push_pop
    subject = NavigationController.new(ViewController.new)
    subject.parent = self
    child = ViewController.new

    subject.begin_appearance_transition(true)
    subject.end_appearance_transition()

    assert subject.appeared?
    assert subject.root_view_controller.appeared?

    subject.push_view_controller(child)

    assert subject.root_view_controller.disappeared?
    assert child.appeared?

    subject.pop_view_controller
    assert child.disappeared?
    assert subject.root_view_controller.appeared?

  end

  def test_pop_to_root
    subject = NavigationController.new(ViewController.new)
    subject.parent = self

    4.times do
      subject.push_view_controller(ViewController.new)
    end

    children = subject.children.dup

    children.each { |child|
      puts child.appearance, child.disappeared?
    }

    children.each { |child| child.reset! }
    last_child = children.pop

    subject.pop_to_root_view_controller()

    assert subject.top_view_controller == subject.root_view_controller
    assert last_child.disappeared?
    # assert !children.any? { |child|
    #   puts child.disappeared?
    #   child.disappeared?
    # }
    assert subject.root_view_controller.appeared?

  end

  def test_move_child
    subject1 = NavigationController.new(ViewController.new)
    subject2 = NavigationController.new(ViewController.new)
    child = ViewController.new
    subject1.parent = self
    subject2.parent = self

    subject1.push_view_controller(child)

    assert subject1.top_view_controller == child
    assert subject2.top_view_controller == subject2.root_view_controller

    subject2.push_view_controller(child)

    assert subject1.top_view_controller == subject1.root_view_controller
    assert subject2.top_view_controller == child
  end

  def refresh
    yield if block_given?
  end

  def force_update
    yield if block_given?
  end

end

