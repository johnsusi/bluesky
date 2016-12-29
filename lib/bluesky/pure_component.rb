
module Bluesky

  module DSL

    module_function

    Clearwater::Component::HTML_TAGS.each do |tag_name|
      define_method(tag_name) do |attributes, content|
        %x{
          if(!(attributes === nil || attributes.$$is_hash)) {
            content = attributes;
            attributes = nil;
          }
        }

        tag(tag_name, attributes, content)
      end
    end

    def tag(tag_name, attributes=nil, content=nil, &block)

      if block
        attributes ||= {}
        content ||= []
        block.call(NodeBuilder.new(tag_name, attributes, content))
      end

      Clearwater::VirtualDOM.node(
        tag_name,
        Clearwater::Component.sanitize_attributes(attributes),
        Clearwater::Component.sanitize_content(content)
      )
    end


  end

  # A presentation `Component`
  class PureComponent

    # Example:
    #
    # class FooView < Bluesky::PureComponent
    #
    #   attribute :times
    #
    #   def render
    #     div([
    #       div("Clicked #{times}!"),
    #       form([
    #         label('Button to click'),
    #         button({ onclick: -> { dispatch(:clicked) } }, [ 'click me!' ])
    #       ])
    #     ])
    #   end
    # end
    #
    # class FooController < Bluesky::ViewController
    #
    #   def initialize
    #     @times = 0
    #   end
    #
    #   def view
    #     FormView.new({ times: @times }, self)
    #   end
    #
    #   def clicked
    #     @times += 1
    #   end
    # end
    if RUBY_ENGINE == 'opal'
    %x{
      Opal.defn(self, 'hook', function(node, propertyName, previousValue) {
        var self = this;
        console.log('hook', node, propertyName, previousValue);
        if (!previousValue) {
          var component_did_mount = self.$component_did_mount;
          if (component_did_mount && !component_did_mount.$$stub) {
            self.$mount();
            self.$component_did_mount();
          }
        }
      });

      Opal.defn(self, 'unhook', function(node, propertyName, previousValue) {
        var self = this;
        console.log('unhook', node, propertyName, previousValue);
        if (!previousValue) {
          var component_will_unmount = self.$component_will_unmount;
          if (component_will_unmount && !component_will_unmount.$$stub) {
            self.$unmount();
            self.$component_will_unmount();
          }
        }

      });
    }
    end

    include Clearwater::Component
    include Clearwater::CachedRender
    include DSL

    @descendants = []

    def self.inherited(subclass)
      DSL.send(:define_method, subclass.name) do |data = {}, delegate = nil, &block|
        delegate ||= @delegate
        component = subclass.new(data, delegate)
        block.call(component) if block
        component
      end

      @descendants << subclass
    end

    def self.install_hooks(debug=false)

      @descendants.each do |subclass|

        if subclass.instance_methods.include?(:component_did_mount) ||
           subclass.instance_methods.include?(:component_will_unmount)
          subclass.class_eval { `Opal.defn(self, '$$mountable', true);` }
        end

        if subclass.instance_methods.include?(:component_will_mount)
          subclass.class_eval { `Opal.defn(self, '$$hook_will_mount', true);` }
        end
        subclass.send(:alias_method, :do_render, :render) unless
          subclass.instance_methods.include?(:do_render)

        subclass.send(:define_method, :render) do
          begin
            $$.console.time("#{subclass.name}:render") if debug
            %x{
              var contents = #{do_render};
              if (self.$$mountable) contents.properties.ref = self;
              return contents;
            }
          rescue Object => err
            warn err
            div({ class: 'broken', style: { display: :none } }, [err.message])
          ensure
            $$.console.timeEnd("#{subclass.name}:render") if debug
          end
        end

      end

    end

    def self.attribute(name, *args)
      case args.length
      when 0
        define_method(name) do |&block|
          if block
            _data.store(name, block)
            block
          else
            _data.fetch(name)
          end
        end
      when 1
        if args[0].respond_to?(:call)
          define_method(name) { _data.fetch(name) { _data.store(name, args[0].call) } }
        else
          define_method(name) { _data.fetch(name, args[0]) }
        end
      else
        raise ArgumentError, %{ wrong number of arguments
                                (#{args.length} for 1..2) }
      end
      define_method("#{name}=") { |value| _data.store(name, value) }
    end

    def initialize(data = {}, delegate = nil)
      @data     = data
      @delegate = delegate
    end

    def shallow_equal?(a, b)
      a.equal?(b) || a.each_pair.all? do |k, v|
        bk = b[k]
        v.equal?(bk) || v.eql?(bk)
      end
    rescue Object => _
      false
    end

    def should_render?(previous)
      # puts "#{self.class.name}:should_render? #{(@delegate && @delegate.force_update?)}, #{!shallow_equal?(_data, previous._data)}"
      (@delegate && @delegate.force_update?) ||
        !shallow_equal?(_data, previous._data)
    end

    def dispatch(action, *payload, &block)
      warn 'Missing delegate' unless @delegate
      root = @delegate
      root = root.parent while root.respond_to?(:parent) && root.parent
      root.dispatch(@delegate, action, *payload, &block)
    end

    def mount
      puts 'mount'
      @mounted = true
    end

    def unmount
      puts 'unmount'
      @mounted = false
    end

    def mounted?
      !!@mounted
    end

    protected

    def _data
      @data
    end

  end
end
