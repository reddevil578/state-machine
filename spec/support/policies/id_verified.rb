module StateMachine
  module GuardPolicy
    class IdVerified
      include StateMachine::Policy

      def required?
        !subject.id_verified?
      end
    end
  end
end
