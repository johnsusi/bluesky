require 'test_helper'

class TestViewController < Minitest::Test

  def test_appear

    subject = Bluesky::ViewController.new

    assert :disappeared, subject.appearance

    subject.begin_appearance_transition(true)

    assert :appearing, subject.appearance

    subject.end_appearance_transition()

    assert :appeared, subject.appearance
    assert subject.appeared?

  end

  def test_disappear

    subject = Bluesky::ViewController.new

    subject.begin_appearance_transition(true)
    subject.end_appearance_transition()

    assert :appeared, subject.appearance

    subject.begin_appearance_transition(false)

    assert :disappearing, subject.appearance

    subject.end_appearance_transition()

    assert :disappeared, subject.appearance
    assert subject.disappeared?

  end

end
