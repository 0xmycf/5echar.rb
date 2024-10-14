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

  private

  def _filter_feats(&)
    @feats = @feats.filter(&) if block_given?
    @class_feats = @class_feats.filter(&) if block_given?
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
    proc = proc { |obj| obj["name"].match?(/#{name}/i) }
    ret = @feats.find(&proc)
    return Feat.new ret["name"], DndAbility.discription(ret["entries"]) unless ret.nil?

    ft = @class_feats.find(&proc)
    Feat.new ft["name"], DndAbility.discription(ft["entries"])
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
    spell = @json.find { |spell_json| spell_json["name"].match?(/#{name}/i) }
    raise "Spell #{name} not found" if spell.nil?

    Spell.new spell
  end

end
