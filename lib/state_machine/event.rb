module StateMachine
  class Event
    attr_accessor :name, :transitions_to

    def initialize(name, transitions_to)
      @name = name
      @transitions_to = transitions_to.to_sym
    end

    def to_s
      @name.to_s
    end
  end
end
