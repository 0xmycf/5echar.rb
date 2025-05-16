# frozen_string_literal: true

# Helpers for rendering typst code
module TypstHelpers

  def self.italic(str)
    "_#{str}_"
  end

  def self.bold(str)
    "*#{str}*"
  end

  def self.h(n, str)
    raise "n must be between 1 and 6" unless n.between?(1, 6)

    str.prepend(" ")
    n.times do
      str.prepend("=")
    end
    str
  end

end
