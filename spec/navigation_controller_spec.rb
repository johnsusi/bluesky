require 'bluesky/navigation_controller.rb'

RSpec.configure do |config|
  config.alias_example_to :they
end

RSpec::Matchers.define :appear do
  match do |actual|
    expect(actual).to receive(:view_will_appear).ordered
    # expect(actual).to receive(:render).ordered
    # expect(actual).to receive(:view).ordered
    expect(actual).to receive(:view_did_appear).ordered
  end
end

RSpec::Matchers.define :disappear do
  match do |actual|
    expect(actual).to receive(:view_will_disappear).ordered
    expect(actual).to receive(:view_did_disappear).ordered
  end
end


RSpec.describe Bluesky::NavigationController do

  subject(:navigation_controller) {
    root_view_controller = Bluesky::ViewController.new
    application = Class.new do

      def force_update(&block)
        block.call
      end

      def refresh(&block)
        block.call
      end

    end.new

    navigation_controller = Bluesky::NavigationController.new(root_view_controller)
    navigation_controller.parent = application
    navigation_controller
  }

  context "when constructed" do
    it "should be hidden" do
      expect(navigation_controller.appearance).to eq(:disappeared)
      expect(navigation_controller.top_view_controller.appearance).to eq(:disappeared)
    end

    it "should have one child" do
      expect(navigation_controller.children.length).to eq(1)
    end

  end

  context "when appearing" do

    it "appears" do
      expect(navigation_controller).to appear
      navigation_controller.begin_appearance_transition(true)
      navigation_controller.render()
      navigation_controller.end_appearance_transition()
    end

    context "root_view_controller" do
      subject(:root_view_controller) { navigation_controller.root_view_controller }

      it "appears" do
        expect(root_view_controller).to appear
        navigation_controller.begin_appearance_transition(true)
        navigation_controller.render()
        navigation_controller.end_appearance_transition()
      end
    end

  end

  context "when appeared" do

    before {
      navigation_controller.begin_appearance_transition(true)
      navigation_controller.end_appearance_transition()
    }

    let(:visible_view_controller) { navigation_controller.visible_view_controller }
    let(:child) { Bluesky::ViewController.new }

    describe "#push_view_controller" do

      it "hides the visible_view_controller" do
        expect(visible_view_controller).to disappear
        navigation_controller.push_view_controller(child)
      end

      it "shows the new view_controller" do
        expect(child).to appear
        navigation_controller.push_view_controller(child)
      end


      it "has child as visible_view_controoler" do
        navigation_controller.push_view_controller(child)
        expect(navigation_controller.visible_view_controller).to eq(child)
      end

    end


    describe "when disappearing" do
      it "disappears" do
        expect(navigation_controller).to disappear
        navigation_controller.begin_appearance_transition(false)
        navigation_controller.end_appearance_transition()
      end

      context "children" do
        they "disappear" do
          expect(navigation_controller.children).to all( disappear )
          navigation_controller.begin_appearance_transition(false)
          navigation_controller.end_appearance_transition()
        end
      end
    end
  end

  # describe "#push_view_controller" do

  #   child = Bluesky::ViewController.new

  #   it "should hide the root_view_controller" do
  #     expect(root_view_controller).to receive(:view_will_disappear).ordered
  #     expect(root_view_controller).to receive(:view_did_disappear).ordered
  #   end

  #   it "should show the child controller" do
  #     expect(child).to receive(:view_will_disappear).ordered
  #     expect(child).to receive(:view_did_disappear).ordered
  #   end

  #   # navigation_controller.push_view_controller(child)

  # end
end
