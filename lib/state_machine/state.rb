require_relative 'named_collection'

module StateMachine
  class State
    attr_accessor :name, :events, :guards, :next_state_name
    attr_reader :spec

    def initialize(name:, spec:)
      @name = name
      @spec = spec
      @events = NamedCollection.new
      @guards = NamedCollection.new
    end

    def next_state
      return nil unless @next_state_name
      spec.states[@next_state_name]
    end

    def to_s
      name.to_s
    end

    def to_sym
      name.to_sym
    end
  end
end
