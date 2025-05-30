# frozen_string_literal: true

require 'json'
require 'pathname'

require_relative 'abilities'

# The base class for a Reader
#
# There are basically 3 readers:
# 1. The Feature Reader
# 2. The Spell reader
# 3. The Background Reader
# (4. The Class Reader?) I could outsource this to this
class Reader

  # Filter only for the PHB'24
  def self.xphb_filter(feat_obj)
    feat_obj["source"].match?(/xphb/i)
  end

  def find(_name); end

  # @return [Array]
  def find_many(names)
    names.map { |n| find n }
  end

end

# The FeatReader reads the feats from
# the feat list
class FeatReader < Reader

  # @param [Pathname] path -- the path for the feats.json file
  def initialize(path, class_feats, &)
    super()
    @feats = JSON.parse(path.read)
    # @type [Array<Hash>]
    @feats = @feats["feat"]
    # @type [Array<Hash>]
    @class_feats = class_feats
    _filter_feats(&)
  end

  # Find the feat named 'name' in the feats.
  # Till search the general Feates before it will search through the class feats
  # @return [Feat]
  def find(name)
    proc = proc { |obj| obj["name"].match?(/^#{name}/i) }
    ret = @feats.find(&proc)
    return Feat.new ret["name"], Ability.description(ret["entries"]) unless ret.nil?

    ft = @class_feats.find(&proc)
    if ft.nil?
      puts "You probably passed in a name (#{name}) which is not available"
    end
    Feat.new ft["name"], Ability.description(ft["entries"])
  end

  private

  def _filter_feats(&)
    @feats = @feats.filter(&) if block_given?
    @class_feats = @class_feats.filter(&) if block_given?
  end

end

# Find spells with this
class SpellReader < Reader

  # @param [Pathname]
  def initialize(path)
    super()
    # @type [Array<Hash>]
    @json = JSON.parse(path.read)["spell"]
  end

  # Find a spell by 'name'
  # @return [Spell]
  def find(name)
    spell = @json.find { |spell_json| spell_json["name"].match?(/^#{name}/i) }
    raise "Spell #{name} not found" if spell.nil?

    Spell.new spell
  end

end

# Reads the Feat from the backgrounds
class BackgroundReader < Reader

  # @param [Pathname] path. The path to the background json
  # @param [Pathname] feat_reader_path. The path that is used by an internal FeatReader
  # @param [Block] the block should be filter.
  # The filter will be applied to the names of the backgrounds
  def initialize(path, feat_reader_path, &filtering)
    super()
    # @type [Array<Hash>]
    @backgrounds = JSON.parse(path.read)["background"].filter(&filtering)
    @frpath = feat_reader_path
    @filtering = filtering
  end

  # @return [Array<BackgroundFeat>]
  def find(name)
    bg = @backgrounds.find { |bg_json| bg_json["name"].match?(/^#{name}/i) }
    feat_names = find_feats bg
    feat_reader = FeatReader.new @frpath, [], &@filtering
    feat_reader.find_many(feat_names).map do |feat|
      BackgroundFeat.from_feat feat, name
    end
  end

  private

  # @return [MatchData]
  # The first element of the MatchData is the name of the feat in lowercase
  # The second element of the MatchData is the name of the source
  def feat_match(entry)
    entry.match(/([a-zA-Z ]+)\|([a-z]+)/)
  end

  # @return [Array<String>]
  def find_feats(bg)
    # @type [Array<Hash>]
    feats = bg["feats"]
    feats.flat_map { |hash| hash.filter { |_, v| v }.keys }
         .map { |str| feat_match(str) }
         .filter { |match_data| match_data[2].match?(/xphb/i) }
         .map { |match_data| match_data[1] }
  end

end
