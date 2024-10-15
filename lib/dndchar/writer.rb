# frozen_string_literal: true

require_relative 'intermediary_builder'

# The writer that outputs the final typst code
class TypstWriter

  # @param [Intermediary]
  # @param [Boolean] compact
  def initialize(intermediary, compact: false)
    @intermediary = intermediary
    @compact = compact
    # @type [Array<String>]
    @doc = []
  end

  # @return [String]
  def write
    @doc << write_doc
    @doc << write_details unless @compact
    @doc << write_feats
    @doc << write_spells
    @doc.join("\n").gsub("@", '\@')
  end

  private

  def write_doc
    "
    #set page(columns: 2, margin: (x: 0pt, y: 0pt))
    #set columns(gutter: 0%)
    #set par(leading: 0em)
    "
  end

  def write_details
    clazz = @intermediary.clazz
    "You are a Level #{@intermediary.level} #{clazz.clazz} (#{clazz.subclass}) called #{@intermediary.name}\n"
  end

  # @param [Symbol] :feats or :spells
  def write_spell_or_feat(getter)
    content = ""
    @intermediary.send(getter).each do |feat_or_spell|
      content += feat_or_spell.to_typst
    end
    content
  end

  def write_feats
    write_spell_or_feat :feats
  end

  def write_spells
    write_spell_or_feat :spells
  end

end
