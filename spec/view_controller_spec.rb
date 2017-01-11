require 'spec_helper'

require 'bluesky/view_controller'

RSpec.describe Bluesky::ViewController do

  context "when constructed" do

    it { is_expected.to have_attributes(:appearance => :disappeared,
                                        :children   => []) }

    describe "#add_child_view_controller" do

      let(:child) { Bluesky::ViewController.new }

      it "should have children" do
        puts 'test'
        expect(subject.children).not_to be_empty
      end

      before do
        puts 'after'
        subject.add_child_view_controller(child)
      end

    end

    context "when appearing" do

      it { is_expected.to appear }

      after do
        subject.begin_appearance_transition(true)
        subject.end_appearance_transition()
      end

    end

  end

  context "when appeared" do

    before do
      subject.begin_appearance_transition(true)
      subject.end_appearance_transition()
    end

    context "when disappearing" do
      it do
        is_expected.to disappear
      end


      after do
        subject.begin_appearance_transition(false)
        subject.end_appearance_transition()
      end


    end

  end





end