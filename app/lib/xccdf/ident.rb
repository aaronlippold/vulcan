module Xccdf
    # Type for a long-term globally meaningful identifier,
  # consisting of a string (ID) and a URI of the naming
  # scheme within which the name is meaningful.
  class Ident
    include HappyMapper

    tag 'ident'

    attribute :system, String, tag: 'system' # required

    content :ident, String
  end
end
