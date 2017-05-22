require 'active_support'
require_relative 'errors'

module StateMachine
  class GuardFactory
    def self.create(name:, blocking:)
      @name = name
      guard_class.new(name: name.to_sym, blocking: blocking)
    end

    private

    def self.guard_class
      ActiveSupport::Inflector.constantize(guard_class_name)
    rescue NameError
      raise MissingGuardError.new("missing guard '#{@name}'")
    end

    def self.guard_class_name
      "StateMachine::#{ActiveSupport::Inflector.classify(@name)}"
    end
  end
end
