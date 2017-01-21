require_relative './view_controller'

module Bluesky

  # Bluesky::NavigationController
  class NavigationController < ViewController

    def initialize(root_view_controller)
      raise 'NavigationController requires a root_view_controller' unless root_view_controller
      super
      add_child_view_controller(root_view_controller)
    end

    def view
      top_view_controller.view
    end

    def view_will_appear
      super
      top_view_controller.begin_appearance_transition(true)
    end

    def view_did_appear
      super
      top_view_controller.end_appearance_transition
    end

    def view_will_disappear
      super
      top_view_controller.begin_appearance_transition(false)
    end

    def view_did_disappear
      super
      top_view_controller.end_appearance_transition
    end

    def root_view_controller
      @children.first
    end

    def top_view_controller
      @children.last
    end

    def visible_view_controller
      top_view_controller
    end

    def view_controllers
      @children
    end

    def view_controllers=(controllers)
      index = @children.index(controllers.last)
      pop_to_root_view_controller(controllers.last) unless index.nil?
      @children.replace(controllers)
    end

    def push_view_controller(view_controller)
      old_view_controller = top_view_controller
      old_view_controller.begin_appearance_transition(false)
      view_controller.begin_appearance_transition(@appearance == :appeared)
      add_child_view_controller(view_controller)
      force_update do
        view_controller.end_appearance_transition
        old_view_controller.end_appearance_transition
      end
      return
    end

    def pop_view_controller
      pre { top_view_controller != root_view_controller }
      popped_view_controller = top_view_controller
      popped_view_controller.begin_appearance_transition(false)
      popped_view_controller.remove_from_parent_view_controller()
      top_view_controller.begin_appearance_transition(@appearance == :appeared)
      force_update do
        top_view_controller.end_appearance_transition()
        popped_view_controller.end_appearance_transition()
      end
      return popped_view_controller
    end

    def pop_to_view_controller(view_controller)
      index = @children.index(view_controller)
      count = index.nil? ? 0 : index + 1
      removed = @children[count..-1]
      @children = @children[0...count]
      removed.each { |child| child.begin_appearance_transition(false) }
      top_view_controller.begin_appearance_transition(@appearance == :appeared)
      force_update do
        top_view_controller.end_appearance_transition()
        removed.each do |child|
          child.parent = nil
          child.end_appearance_transition()
        end
      end
      return removed
    end

    def pop_to_root_view_controller
      pop_to_view_controller(root_view_controller)
    end

  end
end
