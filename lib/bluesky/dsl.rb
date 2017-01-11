require 'clearwater'

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
end