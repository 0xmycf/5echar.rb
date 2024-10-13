# frozen_string_literal: true

require 'optparse'

# Example usage:
#
# dndchar \
# --name "MyRanger" \
# --class Ranger \
# --subclass "Beast Master" \
# --background "Acolyte" \
# --spells "Hunters Mark, Snare, Entanglement" \
# --attributes "10, 10, 10, 10, 10, 10" \ # or --roll-attributes \
# --feats "Brawler, Magic Innate, Supbar Programmer" \
# --pdf MyRanger.pdf # or --json MyRanger.json
#
module Options

  attr_reader :options, :keys

  @options = {}

  class << self

    private

    # @param string [String]
    def parse_list(string)
      string.split(',').map(&:strip)
    end

  end

  @keys = %i[
    name class_ level subclass
    background spells attributes
    roll_attributes feats to_pdf
    to_json from_json
  ]

  def self.parse
    OptionParser.new do |opts|
      opts.banner = "Usage: dndchar [options]"

      opts.on("--name NAME", "Set the name for the character") do |name|
        @options[:name] = name
      end

      # mutliclass?
      opts.on("--class CLASS", "Set the class for the character") do |class_|
        @options[:class_] = class_
      end

      opts.on("--level LEVEL", "Set the level for the character") do |level|
        @options[:level] = level
      end

      opts.on("--subclass SUBCLASS", "Set the subclass for the character") do |subclass|
        @options[:subclass] = subclass
      end

      opts.on("--background BACKGROUND", "Set the background for the character") do |background|
        @options[:background] = background
      end

      opts.on("--spells SPELLS", "Set the spells for the character") do |spells|
        @options[:spells] = parse_list(spells)
      end

      opts.on("--attributes ATTRIBUTES", "Set the attributes for the character") do |attrs|
        @options[:attributes] = parse_list(attrs)
      end

      opts.on("--roll-attributes", "Roll the attributes for the character") do |attrs|
        @options[:roll_attributes] = attrs
      end

      opts.on("--feats FEATS", "Set the feats for the character") do |feats|
        @options[:feats] = parse_list(feats)
      end

      opts.on("--to-pdf FILENAME", "Save the character to a pdf (typst is required)") do |to_pdf|
        @options[:to_pdf] = to_pdf
      end

      opts.on("--to-json FILENAME", "Save the character to json") do |to_json|
        @options[:to_json] = to_json
      end

      opts.on("--from-json FILENAME", "Load the character from json") do |from_json|
        @options[:from_json] = from_json
      end

    end.parse!

    @options
  end

end
