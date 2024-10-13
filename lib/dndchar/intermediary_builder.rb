# frozen_string_literal: true

require 'pathname'
require 'json'

require_relative 'Char'

# Builds the intermediary json object
# we the use to assemble the typst code
class IntermediaryBuilder

  # @param [Char] char
  def initialize(char)
    # @type [Char]
    @char = char
    @json = {
      name: char.name,
      level: char.level,
      feats: [],
      spells: []
    }

    @source = Pathname.new("./data/")
    # @type [Pathname]
    @classes = @source / "class"
  end

  # path = Path("./data/")
  # classes = path / "class"
  # to_find = "fighter"
  def build
    class_content
  end

  private

  # returns the classfile for the class in the char
  # @return [Pathname]
  def classfile
    clazz = @char.class_.downcase
    raise "Not a directory" unless @classes.directory?

    # @param [Pathname] e
    @classes.entries
            .filter { |e| !e.fnmatch?(".*") } # ignore . and ..
            .filter { |e| !e.fnmatch?("*fluff*") && e.fnmatch?("*#{clazz}*") }
            .first
  end

  # @return [Hash]
  def class_content
    path = @classes / classfile
    raise "not readable" unless path.readable?

    json = JSON.parse(path.read)
    json["class"].filter { |e| e["source"].match?(/XPHB/i) }.first
  end

end
