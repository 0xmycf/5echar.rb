# frozen_string_literal: true

require_relative "dndchar/version"
require_relative "dndchar/opt"
require_relative 'dndchar/intermediary_builder'
require_relative 'dndchar/char'
require_relative 'dndchar/writer'

require 'json'

# Main module for the Dndchar gem
module Dndchar

  class Error < StandardError; end

  def self.run
    opts = Options.parse
    # puts opts
    char = Char.new(opts)
    builder = IntermediaryBuilder.new(char)

    intermediate = builder.build
    writer = TypstWriter.new intermediate
    typst = writer.write
    Pathname.new("/tmp/thing.typst").write typst
  end

end
