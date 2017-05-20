module StateMachine
  module Policy
    attr_reader :subject

    def initialize(subject)
      @subject = subject
    end
  end
end
