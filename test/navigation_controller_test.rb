require 'test_helper'

# See test_helper for #appeared?, #disappeared? and #reset!
# test_helper also defines a mock application as parent for all new instances
module TestNavigationController

  class Constructed < Minitest::Test

    include Bluesky

    def setup
      @subject = NavigationController.new(ViewController.new)
    end

    def test_appearing_it_appears
      refute @subject.appeared?
      @subject.begin_appearance_transition(true)
      @subject.end_appearance_transition()
      assert @subject.appeared?
    end

    def test_adding_child_updates_top_view_controller
      child = ViewController.new
      @subject.push_view_controller(child)
      assert_equal child, @subject.top_view_controller
    end

    def test_pop_view_controller_throws
      assert_raises { @subject.pop_view_controller() }
    end

  end

  class Appeared < Minitest::Test

    include Bluesky

    def setup
      @subject = NavigationController.new(ViewController.new)
      @subject.begin_appearance_transition(true)
      @subject.end_appearance_transition()
    end

    def test_when_disappearing_it_disappears
      refute @subject.disappeared?
      @subject.begin_appearance_transition(false)
      @subject.end_appearance_transition()
      assert @subject.disappeared?
    end

    def test_when_appearing_nothing_happens
      @subject.reset!
      @subject.begin_appearance_transition(true)
      @subject.end_appearance_transition()
      refute @subject.appeared?
      refute @subject.disappeared?
    end

    def test_adding_child_then_child_appears
      child = ViewController.new
      @subject.push_view_controller(child)
      assert child.appeared?
    end

  end

  class WithChild < Minitest::Test

    include Bluesky

    def setup
      @subject = NavigationController.new(ViewController.new)
      @child = ViewController.new
      @subject.push_view_controller(@child)
    end

    def test_pop_view_controller_returns_child
      assert_equal @child, @subject.pop_view_controller()
    end

    def test_appearing_shows_both_subject_and_child_but_not_root_view_controller
      @subject.begin_appearance_transition(true)
      @subject.end_appearance_transition()

      assert @subject.appeared?
      assert @child.appeared?
      refute @subject.root_view_controller.appeared?
    end

    def test_moveing_reparents_child
      target = NavigationController.new(ViewController.new)
      target.push_view_controller(@child)
      assert_equal target, @child.parent
    end


  end

  class WithChildren < Minitest::Test

    include Bluesky

    def setup
      @subject = NavigationController.new(ViewController.new)
      @children = [ViewController.new, ViewController.new, ViewController.new]
      @children.each { |child| @subject.push_view_controller(child) }
    end

    def test_pop_view_controller_returns_last_child
      last = @children.last
      assert_equal last, @subject.pop_view_controller()
    end

    def test_appearing_only_shows_last_child
      @subject.begin_appearance_transition(true)
      @subject.end_appearance_transition()
      last = @children.pop
      assert last.appeared?
      refute @subject.root_view_controller.appeared?
      refute @children.any? &:appeared?
    end

    def test_pop_to_root_removes_children
      assert_equal @children, @subject.pop_to_root_view_controller()
    end

  end

  class WithChildrenAndAppeared < Minitest::Test

    include Bluesky

    def setup
      @subject = NavigationController.new(ViewController.new)
      @children = [ViewController.new, ViewController.new, ViewController.new]
      @children.each { |child| @subject.push_view_controller(child) }
      @subject.begin_appearance_transition(true)
      @subject.end_appearance_transition()
    end

    def test_pop_to_root_hides_last_child
      @subject.pop_to_root_view_controller()
      assert @children.last.disappeared?
    end

    def test_pop_to_root_shows_root_view_controller
      @subject.pop_to_root_view_controller()
      assert @subject.root_view_controller.appeared?
    end

    def test_move_top_view_controller_to_hidden_parent_hides_it
      child = @subject.top_view_controller
      target = NavigationController.new(ViewController.new)
      target.push_view_controller(child)
      assert child.disappeared?
    end

  end

end

