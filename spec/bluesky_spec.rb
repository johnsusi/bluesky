require 'bluesky'

class RootView < Bluesky::PureComponent

  def render
    nil
  end
end

class RootViewController < Bluesky::ViewController

  def view
    RootView.new
  end

end

class Application < Bluesky::Application

  def root_view_controller
    @root_view_controller ||= RootViewController.new
  end

end

describe Application do
  context 'when run' do
    it 'calls render on the root_view_controller' do
      application = Application.new
      expect(application.root_view_controller).to receive(:render)
      application.run
    end
  end
end
