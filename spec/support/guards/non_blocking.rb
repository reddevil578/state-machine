module StateMachine
  class Guard
    class NonBlocking
      include StateMachine::Policy

      def required?
        true
      end
    end
  end
end
