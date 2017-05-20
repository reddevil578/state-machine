class Widget
  include StateMachine

  attr_accessor :id_verified

  def id_verified?
    id_verified
  end

  workflow do
    state :new do
      next_state :approved
      event :approve, transitions_to: :approved
      event :reject, transitions_to: :rejected
    end
    state :approved do
      guard :id_verified
      guard :non_blocking, blocking: false
    end
    state :rejected
  end
end
