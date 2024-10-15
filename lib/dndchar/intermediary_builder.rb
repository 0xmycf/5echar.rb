# frozen_string_literal: true

require 'pathname'
require 'json'

require_relative 'char'
require_relative 'reader'
require_relative 'abilities'

# Builds the intermediary json object
# we the use to assemble the typst code
class IntermediaryBuilder

  # @param [Char] char
  def initialize(char)
    # @type [Char]
    @char = char
    @json = {
      dndchar_class: {
        date: Time.now,
        char:
      },
      name: char.name,
      clazz: DndClass.new(char.class_, char.subclass),
      level: char.level,
      feats: [],
      spells: []
    }

    @source = Pathname.new("./data/")
    # @type [Pathname]
    @classes = @source / "class" # the directory with all the classes
    # @type [Pathname]
    @feats = @source / "feats.json" # the feats file
    # @type [Pathname]
    @spells = @source / "spells" / "spells-xphb.json"
    # @type [Pathname]
    @backgrounds = @source / "backgrounds.json"
  end

  # path = Path("./data/")
  # classes = path / "class"
  # to_find = "fighter"
  def build
    cc = class_content
    @json[:feats] = feats(cc) + other_feats + background_feats
    @json[:spells] = spells

    Intermediary.new @json
  end

  private

  ClassContent = Struct.new(:class_json, :classFeatures) do
    def self.make(json)
      ClassContent.new(
        json["class"].filter { |e| e["source"].match?(/XPHB/i) }.first,
        json["classFeature"]
      )
    end
  end

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

  # @return [ClassContent], the first element is the class's json
  # anad the second element is the list of classFeatures (unfiltered)
  def class_content
    path = @classes / classfile
    raise "not readable" unless path.readable?

    json = JSON.parse(path.read)
    ClassContent.make json
  end

  # Retrieve the class feats of the given class
  # @param [ClassContent]
  # @return [Array<Feat>]
  def feats(content)
    # @type [Array<String>]
    cfeats = content.classFeatures
    feat_reader = FeatReader.new(@feats, cfeats, &Reader.method(:xphb_filter))
    # @param [FeatEntry] feat_entry
    content.class_json["classFeatures"] # map over all *available* features
           .map { |e| FeatEntry.new e }
           .filter { |feat_entry| feat_entry.level <= @char.level }
           .map { |feat_entry| feat_reader.find(feat_entry.name) }
           # @param [Feat] feat
           .filter { |feat| !feat.name.match(/subclass/i) }
  end

  # TODO: rewrite to array of Feat
  # @return [Array<Feat>]
  def other_feats
    feat_reader = FeatReader.new(@feats, [], &Reader.method(:xphb_filter))
    feat_reader.find_many(@char.feats)
  end

  def background_feats
    backgrond_feat_reader = BackgroundReader.new @backgrounds, @feats, &Reader.method(:xphb_filter)
    backgrond_feat_reader.find(@char.background)
  end

  # @return [Array<Spell>]
  def spells
    spell_reader = SpellReader.new @spells
    spell_reader.find_many(@char.spells)
  end

end

# The intermediary representation of the json
class Intermediary

  attr_accessor :json

  def initialize(json)
    @json = json
  end

  # Some problems with this:
  # 1. Didnt work well
  # 2. No autocomplete
  #
  # # @param [String] key
  # @json.each_key do |key|
  #   Intermediary.define_method(key.to_sym) { @json[key] }
  # end

  # @return [Hash] Hash with keys :date (Time.now result) and :char (Hash)
  def dndchar_class
    @json[:dndchar_class]
  end

  # @return [String] The name of the char
  def name
    @json[:name]
  end

  # @return [DndClass] The class of the char
  def clazz
    @json[:clazz]
  end

  # @return [Integer] The level of the char
  def level
    @json[:level]
  end

  # @return [Array<Feat>] The feats
  def feats
    @json[:feats]
  end

  # @return [Array<Spell>] The spell
  def spells
    @json[:spells]
  end

end

# Convenience Class for dealing with the Feat
# entries in the json
class FeatEntry

  attr_reader :name, :clazz, :source, :level

  # @param [String | Hash]
  def initialize(feat_string)
    feat_string = feat_string["classFeature"] if feat_string.is_a? Hash
    from_string feat_string
  end

  def from_string(feat_string)
    things = feat_string.split("|")
    @name = things[0]
    @clazz = things[1] # this is usally known from context, but we store it anyway
    @source = things[2]
    @level = things[3].to_i # the required level
  end

end
