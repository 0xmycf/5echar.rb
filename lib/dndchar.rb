# frozen_string_literal: true

require_relative "dndchar/version"
require_relative "dndchar/opt"
require_relative 'dndchar/intermediary_builder'
require_relative 'dndchar/char'

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
    puts JSON.pretty_generate(intermediate.json)
    puts "---"
    typst_spell = intermediate.json[:spells].first.to_typst
    Pathname.new("/tmp/spell.typst").write typst_spell
  end

end
