require 'active_support'
require_relative 'errors'

module StateMachine
  class Guard
    attr_reader :name, :blocking, :policy_class

    def initialize(name:, blocking: true)
      @name = name.to_sym
      @blocking = blocking
      @policy_class = policy_class
    end

    def policy_class
      @policy_class ||= ActiveSupport::Inflector.constantize(policy_class_name)
    rescue NameError
      raise MissingGuardError.new("missing guard '#{name}'")
    end

    def to_s
      @name.to_s
    end

    private

    def policy_class_name
      "StateMachine::Guard::#{ActiveSupport::Inflector.classify(name)}"
    end
  end
end
