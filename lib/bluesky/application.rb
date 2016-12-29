module Bluesky

  # Bluesky::Application
  class Application

    include DOMHelper

    attr_accessor :root_view_controller, :debug, :delegate

    def initialize
      @dispatch_queue = []
      @debug = false
    end

    def debug?
      @debug
    end

    def debug!
      @debug = true
      @clearwater.debug! if @clearwater
      @delegate = DebugDelegate.new(@delegate)
      self
    end

    def dispatch(target, action, *payload, &block)
      promise = Promise.new
      delegate.try(:dispatch, target, action, *payload)
      @dispatch_queue << lambda do
        begin
          result = target.send(action, *payload, &block)
          promise.resolve(result).then { refresh }
          delegate.try(:dispatch_resolved, target, action, *payload, result)
        rescue => err
          promise.reject(err)
          delegate.try(:dispatch_rejected, target, action, *payload, err)
        end
      end
      defer { process_dispatch_queue }
      promise
    end

    def process_dispatch_queue
      return if @dispatch_queue.empty?
      @dispatch_queue.delete_if do |task|
        task.call
        true
      end
    end

    def notify(source, event, *payload)
      @delegate.try(:notify, source, event, *payload)
    end

    def refresh(&block)
      promise = Promise.new
      @clearwater.call { promise.resolve }
      block ? promise.then(&block) : promise
    end

    def run
      raise 'root_view_controller must be defined in Application' unless root_view_controller
      PureComponent.install_hooks(debug?)
      root_view_controller.parent = self
      @clearwater = Clearwater::Application.new(component: root_view_controller)
      @clearwater.debug! if debug?
      root_view_controller.begin_appearance_transition(true)
      refresh { root_view_controller.end_appearance_transition() }
      self
    end

  end

  class DebugDelegate

    def initialize(delegate = nil)
      @delegate = delegate
    end
    def dispatch(target, action, *payload)
      @delegate.try(:dispatch, target, action, *payload)
      puts "[DISPATCH] #{action} on #{target}"
    end

    def dispatch_resolved(target, action, *payload, result)
      @delegate.try(:dispatch_resolved, result, target, action, *payload)
      puts "[RESOLVED] #{action} on #{target} yielding #{result}"
    end

    def dispatch_rejected(target, action, *payload, error)
      @delegate.try(:dispatch_rejected, target, action, *payload, error)
      puts "[REJECTED] #{action} on #{target}"
      warn error
    end

    def notify(source, event, *payload)
      puts "[NOTIFY] #{event} from #{source}"
    end

  end

end

