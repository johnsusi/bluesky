require 'test_helper'

# See test_helper for #appeared?, #disappeared? and #reset!
module TestViewController

  class Constructed < Minitest::Test

    include Bluesky

    def setup
      @subject = ViewController.new
    end

    def test_appearing_it_appears
      @subject.begin_appearance_transition(true)
      @subject.end_appearance_transition()
      assert @subject.appeared?
    end

    def test_add_child_view_controller_reparents_child
      child = ViewController.new
      assert_nil child.parent
      @subject.add_child_view_controller(child)
      assert_equal @subject, child.parent
    end

  end

end
