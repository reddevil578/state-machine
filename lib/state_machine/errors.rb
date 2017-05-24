module StateMachine
  class Error < StandardError; end

  class NoTransitionAllowed < Error; end

  class WorkflowDefinitionError < Error; end

  class MissingGuardError < Error; end
end
