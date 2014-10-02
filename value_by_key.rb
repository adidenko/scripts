#
# value_by_key.rb
#

module Puppet::Parser::Functions
  newfunction(:value_by_key, :type => :rvalue, :doc => <<-EOS
Returns a value by given key from the hash.

*Examples:*

    $hash = {
      'a' => 1,
      'b' => 2,
      'c' => 3,
    }
    value_by_key($hash, 'b')

This example would return:

    2
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "value_by_key(): Wrong number of arguments " +
      "given (#{arguments.size} for 2)") if arguments.size != 2

    hash = arguments[0]
    key = arguments[1]

    unless hash.is_a?(Hash)
      raise(Puppet::ParseError, 'value_by_key(): Requires hash to work with')
    end

    result = hash[key]

    return result
  end
end

# vim: set ts=2 sw=2 et :
