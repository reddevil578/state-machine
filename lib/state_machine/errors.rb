module StateMachine
  class Error < StandardError; end

  class WorkflowDefinitionError < Error; end

  class MissingPolicyError < Error; end
end
