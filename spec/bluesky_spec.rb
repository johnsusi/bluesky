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

  root_view_controller RootViewController

end

describe Application do
  context 'when run' do
    it 'calls render on the root_view_controller' do
      logger = double()
      application = Application.new
      application.logger = logger
      expect(logger).to receive(:render).with(application)
      application.run
    end
  end
end
