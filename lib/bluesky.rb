require 'opal'
require 'clearwater'
#require 'clearwater/cached_render'

module Clearwater
  module CachedRender
    class Wrapper
      attr_reader :content

      def initialize content
        @content = content
        @key = content.key
      end

      if RUBY_ENGINE == 'opal'
      # Hook into vdom diff/patch
      %x{
        def.type = 'Thunk';
        def.render = function cached_render(prev) {
          var self = this;
          if(prev && prev.vnode && #{!@content.should_render?(`prev.content`)}) {
            self.content = prev.content;
            return prev.vnode;
          } else {
            var content = #{Component.sanitize_content(@content.render)};
            while(content && content.type == 'Thunk' && content.render) {
              content = #{Component.sanitize_content(`content.render(prev)`)};
            }
            return content;
          }
        };
      }
      end
    end
  end
end

require_relative 'bluesky/helpers.rb'
require_relative 'bluesky/node_builder.rb'
require_relative 'bluesky/pure_component.rb'
require_relative 'bluesky/view_controller.rb'
require_relative 'bluesky/navigation_controller.rb'
require_relative 'bluesky/application.rb'
require_relative 'bluesky/version'

unless RUBY_ENGINE == 'opal'
  begin
    require 'opal'
    Opal.append_path File.expand_path('..', __FILE__).untaint
  rescue LoadError
  end
end
