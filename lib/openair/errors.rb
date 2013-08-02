module OpenAir
  module Errors
    def self.new(type, message=nil)
      unless self.const_defined?(type)
        self.const_set type.intern, Class.new(StandardError) do
          attr_reader :message

          def initialize(message=nil)
            @message = message
          end
        end
      end

      self.const_get(type).new(message)
    end
  end
  class RecordNotFound < StandardError; end
  class InitializationError < StandardError; end
  class ConfigurationError < StandardError; end
  class ReadError < StandardError; end
  class LoginError < StandardError; end
  class AuthError < StandardError; end
  class UnknownError < StandardError; end
  class CreateUserError < StandardError; end
end
