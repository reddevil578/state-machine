module StateMachine
  class NonBlocking
    include StateMachine::Guard

    def required?(subject)
      true
    end
  end
end
