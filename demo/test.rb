
module DSL

  module Core
    def button
      'button'
    end
  end

end

class Component

  include DSL
  include DSL::Core

  def initialize
    return self.render
  end

end

module DSL

  def button
    'new button'
  end
end

class Notification < Component

  def render
    button
  end
end


puts Notification.new.render