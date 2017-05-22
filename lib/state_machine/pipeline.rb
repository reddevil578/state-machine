module StateMachine
  class Pipeline
    attr_accessor :name, :workflows

    def initialize(name:)
      @name = name
      @workflows = []
    end
  end
end
