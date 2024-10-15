# frozen_string_literal: true

require 'json'

# Inherit from this to get automatic json functionality
module JSONable

  def to_json(*options)
    hash = {}
    instance_variables.each do |var|
      hash[var.to_s[1..]] = instance_variable_get var
    end
    hash.to_json(*options)
  end

  # @param [String] string
  def from_json!(string)
    JSON.parse(string).each do |var, val|
      instance_variable_set "@#{var}", val
    end
  end

end
