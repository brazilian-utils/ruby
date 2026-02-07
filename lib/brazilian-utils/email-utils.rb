module BrazilianUtils
  module EmailUtils
    # Email validation pattern based on RFC 5322
    # This pattern validates:
    # - Email must not start with a dot
    # - Local part (before @): alphanumeric, dots, underscores, percent, plus, minus
    # - @ symbol required
    # - Domain part: alphanumeric, dots, hyphens
    # - Dot separator required
    # - TLD: at least 2 alphabetic characters
    EMAIL_PATTERN = /\A(?![.])[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\z/.freeze

    # Checks if a string corresponds to a valid email address.
    #
    # This function validates email addresses following the specifications defined 
    # by RFC 5322, which is the widely accepted standard for email address formats.
    #
    # @param email [String] The input string to be checked
    #
    # @return [Boolean] Returns true if email is a valid email address, false otherwise
    #
    # @example Valid emails
    #   is_valid("brutils@brutils.com")       #=> true
    #   is_valid("user.name@example.com")     #=> true
    #   is_valid("user+tag@example.co.uk")    #=> true
    #   is_valid("user_123@test-domain.com")  #=> true
    #
    # @example Invalid emails
    #   is_valid("invalid-email@brutils")     #=> false (no TLD)
    #   is_valid(".user@example.com")         #=> false (starts with dot)
    #   is_valid("user@")                     #=> false (no domain)
    #   is_valid("@example.com")              #=> false (no local part)
    #   is_valid("user name@example.com")     #=> false (space not allowed)
    #   is_valid(nil)                         #=> false (not a string)
    #
    # @note The validation rules generally follow RFC 5322 specifications:
    #   - Local part cannot start with a dot
    #   - Local part can contain: letters, numbers, dots, underscores, percent, plus, minus
    #   - Must have @ symbol
    #   - Domain can contain: letters, numbers, dots, hyphens
    #   - Must have at least one dot in domain
    #   - TLD must be at least 2 characters and only letters
    def self.is_valid(email)
      return false unless email.is_a?(String)

      EMAIL_PATTERN.match?(email)
    end

    # Alias for is_valid to provide alternative naming convention
    class << self
      alias valid? is_valid
    end
  end
end
