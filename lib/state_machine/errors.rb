module StateMachine
  class Error < StandardError; end

  class WorkflowDefinitionError < Error; end

  class MissingGuardError < Error; end
end
