require 'clearwater'
require_relative './dom_helper'
require_relative './dsl'

module Bluesky

  class ViewController

    include Clearwater::Component
    include DOMHelper
    include DSL

    def self.attribute(name, *args, &block)
      case args.length
      when 0
        define_method(name) { data.fetch(name) }
      when 1
        if args[0].respond_to?(:call)
          define_method(name) { data.fetch(name) { data.store(name, args[0].call) } }
        else
          define_method(name) { data.fetch(name, args[0]) }
        end
      else
        raise ArgumentError, %{ wrong number of arguments
                                (#{args.length} for 1..2) }
      end
      define_method("#{name}=") { |value| data.store(name, value) }
    end

    def self.inherited(subclass)
      define_method(subclass.name) do |**data|
        subclass.new(delegate: self, data: data)
      end
    end

    attr_accessor :children, :parent, :data, :appearance

    def initialize(*_, children: [], parent: nil, data: {})
      @children = children
      @parent = parent
      @data = data
      @appearance = :disappeared
      @force_update = false
      @delegate = self
    end

    def force_update?
      @force_update
    end

    def view
      nil
    end

    def render
      view
    end

    def dispatch(target, action, *payload, &block)
      parent.try(:dispatch, target, action, *payload, &block)
    end

    def notify(source, event, *payload)
      parent.try(:notify, source, event, *payload)
    end

    def begin_appearance_transition(appearing)
      if appearing
        return unless @appearance == :disappeared
        # raise "Invalid appearance #{@appearance} when appearing" if @appearance != :disappeared
        @appearance = :appearing
        view_will_appear()
      else
        return unless @appearance == :appeared
        # raise "Invalid appearance #{@appearance} when disappearing" if @appearance != :appeared
        @appearance = :disappearing
        view_will_disappear()
      end
    end

    def end_appearance_transition()
      case @appearance
      when :appearing
        @appearance = :appeared
        view_did_appear()
      when :disappearing
        @appearance = :disappeared
        view_did_disappear()
      else
        # raise "Invalid appearance #{@appearance} when transitioning"
      end
    end

    def add_child_view_controller(view_controller)
      view_controller.will_move_to_parent_view_controller(self)
      view_controller.remove_from_parent_view_controller
      children.push(view_controller)
      view_controller.parent = self
      view_controller.did_move_to_parent_view_controller(self)
    end

    def remove_from_parent_view_controller
      return unless parent
      parent.children.delete(self)
    end

    def show(_view_controller)
      raise 'not implemented'
    end

    def present(_view_controller)
      raise 'not implemented'
    end

    def dismiss
      raise 'not implemented'
    end

    def navigation_controller
      parent.is_a?(NavigationController) ? parent :
        parent.try(:navigation_controller)
    end

    # Callbacks

    def will_move_to_parent_view_controller(view_controller)
    end

    def did_move_to_parent_view_controller(view_controller)
    end

    def view_will_appear
    end

    def view_did_appear
    end

    def view_will_disappear
    end

    def view_did_disappear
    end

    # Dispatch methods

    def force_update
      @force_update = true
      @parent.refresh do
        @force_update = false
        yield if block_given?
      end
    end

    def refresh(&block)
      @parent.refresh(&block)
    end

  end
end