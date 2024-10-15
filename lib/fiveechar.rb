# frozen_string_literal: true

require_relative "fiveechar/version"
require_relative "fiveechar/opt"
require_relative 'fiveechar/intermediary_builder'
require_relative 'fiveechar/char'
require_relative 'fiveechar/writer'

require 'json'

# Main module for the 5echar gem
module FiveeChar

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
