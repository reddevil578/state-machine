module StateMachine
  module GuardPolicy
    class NonBlocking
      include StateMachine::Policy

      def required?
        true
      end
    end
  end
end
