class MissingGuardPolicy
  include StateMachine

  workflow do
    state :new do
      guard :missing_guard
    end
  end
end
