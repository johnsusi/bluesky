module Bluesky

  # The application entry point
  class Application

    include DOMHelper
    include TryHelper

    # Top level ViewController
    attr_accessor :root_view_controller

    # Receives all notifications
    attr_accessor :delegate

    def initialize
      @dispatch_queue = []
      @debug = false
    end

    def debug?
      @debug
    end

    # Turns on debug logging
    def debug!
      @debug = true
      self
    end

    # Dispatches an action on target
    #
    # Attributes:
    #   target:  (Object) The object that receives the send action
    #   action   (Symbol) The method symbol on target
    #   payload: (Array)  The arguments passed to send if any
    #   block:   (Block)  Optional block that will be passed as argument to send
    def dispatch(target, action, *payload, &block)
      promise = Promise.new
      notify(self, :dispatch_requested, target, action, *payload)
      @dispatch_queue << lambda do
        begin
          result = target.send(action, *payload, &block)
          promise.resolve(result).then { refresh }
          notify(self, :dispatch_resolved, target, action, *payload, result)
        rescue => err
          promise.reject(err)
          notify(self, :dispatch_rejected, target, action, *payload, err)
        end
      end
      defer { process_dispatch_queue }
      promise
    end


    # Notifies the delegate about an event
    #
    # Attributes:
    #   source:  (Object) The object that send the event
    #   event:   (Symbol) The event symbol
    #   payload: (Array)  Additional arguments to pass along
    def notify(source, event, *payload)
      try(@delegate, source, event, *payload)
      puts "#{event} #{payload}" if debug?
    end

    # Refreshes (runs render) on the root_view_controller and invokes the block
    # (if any) when the render is complete.
    def refresh(&block)
      promise = Promise.new
      @clearwater.call { promise.resolve }
      block ? promise.then(&block) : promise
    end

    # Does the required wiring and runs the initial render
    def run
      raise 'root_view_controller must be defined in Application' unless root_view_controller
      PureComponent.install_hooks(debug?)
      root_view_controller.parent = self
      router = RUBY_ENGINE != 'opal' ?
        Clearwater::Router.new(location: 'http://localhost:9292/') :
        Clearwater::Router.new
      @clearwater = Clearwater::Application.new(
        component: root_view_controller,
        router: router
      )
      @clearwater.debug! if debug?
      root_view_controller.begin_appearance_transition(true)
      refresh { root_view_controller.end_appearance_transition() }
      self
    end

    private

    # Processes queued dispatches
    def process_dispatch_queue
      return if @dispatch_queue.empty?
      @dispatch_queue.delete_if do |task|
        task.call
        true
      end
    end

  end

end

