# frozen_string_literal: true

require_relative 'typst_helpers'

# Parses and evaluaates stuff like {@variantrule foobar}
# or {@dice 1d10}
#
#
# TODO
# instead of just transfering this into a string / typst string
# We should also save the data and look it up in the json files and assemble
# an additional pdf page as appendix to the main pdf for reference.
class InlineInfo

  # @param [MatchData] match
  def initialize(match)
    @match = match
    @kind = match[:kind]
    @body = match[:body]
  end

  # @return [String] content
  def to_typst
    case @kind
    when Kind::VARIANT_RULE, Kind::FILTER, Kind::FEAT, Kind::ACTION, Kind::CONDITION
      take_first_of_body
    when Kind::DICE
      dice
    else
      raise "Unknown kind: #{@kind}"
    end
  end

  private

  def take_first_of_body
    TypstHelpers.italic @body.split('|')[0].to_s
  end

  def dice
    TypstHelpers.bold @body
  end

  def not_implemented
    @match
  end

end

module Kind

  VARIANT_RULE = 'variantrule'
  DICE = 'dice'
  FILTER = 'filter'
  FEAT = 'feat'
  ACTION = 'action'
  CONDITION = 'condition'
  UNKNOWN = 'unknown'

end
