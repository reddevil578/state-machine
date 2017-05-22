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

  def approve(*args)
    puts 'Running custom `approve` method'
  end

  def on_new_exit(new_state, event_name, *args)
    puts "Exiting :new state to :#{new_state} via '#{event_name}'"
  end

  def on_approved_ready
    puts "READY FOR APPROVAL"
  end

  def on_approved_entry(prior_state, event_name, *args)
    puts "Entering :approved state from :#{prior_state} via '#{event_name}'"
  end
end
