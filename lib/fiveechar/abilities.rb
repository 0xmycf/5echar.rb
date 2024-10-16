# frozen_string_literal: true

require_relative 'autojson'

# Something like a Feat or a Spell in the World
# this is something we render in the typst code later on.
class Abilitiy

  def initialize(name, discription)
    @name = name
    @discription = discription
  end

  def render_header
    "= #{@name}"
  end

  def in_box(content)
    "#box(
       width: 100%,
       stroke: 1pt,
       inset: 4pt,
       outset: 0pt,
       [
       #set par(leading: 0.3em)
       #{render_header}
       #{content}
       ]
     )
    "
  end

  def to_typst
    in_box @discription
  end

  # @param [Hash] something like [ "A fluff of wind", {"type": "entries", "name": "my name", "entries": ["same thing"] ]
  # @return [String]
  def self.discription(entries_obj)
    ret = []
    return "" if entries_obj.nil? || entries_obj.empty?

    entries_obj.each do |entry|
      case entry
      when Hash
        ret << "*#{entry['name']}* #{discription(entry['entries'])}"
      when String
        ret << entry
      else
        raise "Entries has entry that was unexpected to me (#{entry.class}) '#{entry}'"
      end
    end
    ret.join "\n\n"
  end

end

# A feat
class Feat < Abilitiy

  include JSONable

  attr_reader :name, :discription

end

# A Feat from the Background,
# it extends the normal feat by holding a reference to the
# Background and renders it to the typst code too
class BackgroundFeat < Feat

  def initialize(name, discription, background)
    super(name, discription)
    @background = background
  end

  # @param [Feat] feat. The feat we extend on
  # @param [String] bg_name. the name of the background
  def self.from_feat(feat, bg_name)
    BackgroundFeat.new feat.name, feat.discription, bg_name
  end

  def render_header
    "= #{@name} (#{@background})"
  end

end

# A spell
class Spell < Abilitiy

  include JSONable

  def initialize(spell_json_obj)
    super spell_json_obj["name"], Spell.discription(spell_json_obj["entries"])
    @level = spell_json_obj["level"]
    @casting_time = Spell.casting_time(spell_json_obj["time"].first) # is the first call sus?
    @range = Spell.range(spell_json_obj["range"])
    # @type [Array<String>]
    @components = Spell.components(spell_json_obj['components'])
    dur = spell_json_obj['duration'].first # sus first call
    @duration = Spell.duration(dur)
    # @type [Boolean]
    @concentration = Spell.concentration(dur)
  end

  def render_header
    "= #{@name} (#{render_level})
    #align(center, [Casting: *#{@casting_time}*   Duration: *#{@duration}*   Range: *#{@range}*])

    #align(center, [*#{@components}*] )
    "
  end

  def render_level
    return "Cantrip" if @level.zero?

    "Level #{@level}"
  end

  # @param [Hash] something like { "number": 1, "unit": "action" }
  # @return [String]
  def self.casting_time(time_obj)
    num = time_obj["number"]
    ret = "#{num} #{time_obj['unit']}"
    ret += "s" if num > 1
    ret
  end

  # @param [Hash] something like { "type" : "point", "distance": { "type": "feet", "amount": 60 } }
  # we ignore the type right now
  # @return [String]
  def self.range(range_obj)
    dist = range_obj["distance"]
    "#{dist['amount']} #{dist['type']}"
  end

  # @param [Hash] components_obj something like { "v": true, "s: true } we ignore the type right now
  # @return [String]
  def self.components(components_obj)
    components_obj.keys.map(&:upcase).join ','
  end

  # @param [Hash] components_obj something like { "type": "timed", "duration": { "type": "hour", amount 8 } }
  # @return [String]
  def self.duration(duration_obj)
    return "Instant" if duration_obj["type"].match?(/instant/i)

    dur = duration_obj["duration"]
    num = dur['amount']
    ret = "#{num} #{dur['type']}"
    ret += "s" if num > 1
    ret
  end

  # @param [Hash] components_obj something like { "concentration": true, "type": "timed", "duration": { "type": "hour", amount 8 } }
  # @return [Boolean]
  def self.concentration(duration_obj)
    lookup = duration_obj["concentration"]
    return false if lookup.nil?

    lookup
  end

end
