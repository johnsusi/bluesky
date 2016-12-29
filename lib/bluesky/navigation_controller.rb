module Bluesky

  # Bluesky::NavigationController
  class NavigationController < ViewController

    attr_accessor :root_view_contrller

    def initialize(root_view_controller)
      raise 'NavigationController requires a root_view_controller' unless root_view_controller
      super
      add_child_view_controller(root_view_controller)
    end

    def view
      top_view_controller.view
    end

    def view_will_appear
      top_view_controller.begin_appearance_transition(true)
    end

    def view_did_appear
      top_view_controller.end_appearance_transition
    end

    def view_will_disappear
      top_view_controller.end_appearance_transition(false)
    end

    def view_did_disappear
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

    def push_view_controller(view_controller)
      old_view_controller = top_view_controller
      old_view_controller.begin_appearance_transition(false)
      view_controller.begin_appearance_transition(true)
      add_child_view_controller(view_controller)
      force_update do
        view_controller.end_appearance_transition
        old_view_controller.end_appearance_transition
      end
    end

    def pop_view_controller
      return nil if top_view_controller == root_view_controller
      old_view_controller = top_view_controller
      old_view_controller.begin_appearance_transition(false)
      old_view_controller.remove_from_parent_view_controller
      top_view_controller.begin_appearance_transition(true)
      force_update do
        top_view_controller.end_appearance_transition
        old_view_controller.end_appearance_transition
      end
    end

    def pop_to_view_controller(view_controller)
      result = []
      result << pop_view_controller while top_view_controller != view_controller
    end

    def pop_to_root_view_controller
      pop_to_view_controller(root_view_controller)
    end

  end
end
