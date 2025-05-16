require "test_helper"
require "fiveechar/typst_helpers"

class TestDie < Minitest::Test

  def test_bold
    assert_equal "*foobar*", TypstHelpers.bold("foobar")
  end

  def test_italic
    assert_equal "_foobar_", TypstHelpers.italic("foobar")
  end

  (1..6).each do |i|
    define_method("test_h_#{i}") do
      assert_equal "#{'=' * i} foobar", TypstHelpers.h(i, "foobar")
    end
  end

  def test_h_too_high
    assert_raises(RuntimeError) do
      TypstHelpers.h(7, "foobar")
    end
  end

  def test_h_too_low
    assert_raises(RuntimeError) do
      TypstHelpers.h(0, "foobar")
    end
  end

end
