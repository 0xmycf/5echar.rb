# frozen_string_literal: true

require "test_helper"
require "fiveechar/char"

class TestDie < Minitest::Test

  def test_4d6kh3
    keep_highest = 3
    die = Die.new 6, kh: keep_highest
    rest = die.roll_n(4)
    assert_equal keep_highest, rest.length
    assert(rest.sum <= 18)
    assert(rest.sum >= 3)
  end

  def test_6_4d6kh3
    keep_highest = 3
    die = Die.new 6, kh: keep_highest
    rest = die.sum_of(6, 4)
    assert_equal 6, rest.length
    assert rest.sum <= (18 * 6)
    assert rest.sum >= (3 * 6)
  end

end
