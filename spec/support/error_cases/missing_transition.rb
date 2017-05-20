class MissingTransition
  include StateMachine

  workflow do
    state :new do
      event :age
    end
    state :old
  end
end
