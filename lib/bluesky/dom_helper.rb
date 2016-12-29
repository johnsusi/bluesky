module Bluesky
  module DOMHelper

    extend self

    protected

    # Delays execution to the main event loop
    #
    # == Parameters:
    # block
    #   A block to execute on the main event loop
    #
    # == Returns:
    # A promise that resolves after block has completed
    def defer(&block)
      timeout(0, &block)
    end

    def delay(hours: 0, minutes: 0, seconds: 0, milliseconds: 0, &block)
      timeout(((hours * 60 + minutes) * 60 + seconds) * 1000 + milliseconds, &block)
    end

    private

    def timeout(milliseconds, &block)
      promise = Promise.new
      $$[:setTimeout].call(-> { promise.resolve }, milliseconds)
      block ? promise.then(&block) : promise
    end

    def self.included(base)
      base.extend(self)
    end

  end
end
