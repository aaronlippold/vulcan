module Xccdf
  # Data type for the Group element that represents a grouping of
  # Groups, Rules and Values.
  class Item
    class SelectableItem
      class Group
        include HappyMapper

        tag 'Group'


        has_many :value, Value, tag: 'Value'
        has_many :rule, Rule, tag: 'Rule'
        has_many :group, Group, tag: 'Group'
        # has_one :signature, String, tag: 'signature'
      end
    end
  end
end
