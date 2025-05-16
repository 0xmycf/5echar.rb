# frozen_string_literal: true

require_relative "fiveechar/version"
require_relative "fiveechar/opt"
require_relative 'fiveechar/intermediary_builder'
require_relative 'fiveechar/char'
require_relative 'fiveechar/writer'

require 'tempfile'

# Main module for the 5echar gem
module FiveeChar

  class Error < StandardError; end

  def self.run
    opts = Options.parse
    # puts opts
    char = Char.new(opts)
    builder = IntermediaryBuilder.new(char)

    intermediate = builder.build

    if opts[:to_json]
      path = Pathname.new opts[:to_json]
      raise "Path #{path} already exists" if path.exist? && !opts[:override]

      path.write  JSON.pretty_generate(intermediate.json)
    elsif opts[:to_pdf]
      path = Pathname.new opts[:to_pdf]
      raise "Path #{path} already exists" if path.exist? && !opts[:override]

      typst = TypstWriter.new(intermediate).write
      tmpfile = Tempfile.new("#{opts[:name]}-5echar")
      tmpfile.write(typst)
      tmpfile.rewind
      args = ["typst", "compile", tmpfile.path, path.to_path]
      system args.join(' '), exception: true
    end

  end

end
