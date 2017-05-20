require_relative 'state'
require_relative 'event'
require_relative 'guard'
require_relative 'errors'

module StateMachine
  class Specification
    attr_accessor :states, :initial_state

    def initialize(&specification)
      @states = {}
      instance_eval(&specification)
    end

    def state_names
      states.keys
    end

    private

    def state(name, &events_and_guards)
      new_state = State.new(name: name, spec: self)
      @initial_state = new_state if @states.empty?
      @states[name.to_sym] = new_state
      @scoped_state = new_state
      instance_eval(&events_and_guards) if block_given?
    end

    def next_state(name)
      @scoped_state.next_state_name = name
    end

    def event(name, opts = {})
      target = opts[:transitions_to]
      raise WorkflowDefinitionError.new(
        "missing ':transitions_to' in workflow event definition for '#{name}'"
      ) if target.nil?
      @scoped_state.events.push(name, Event.new(name, target))
    end

    def guard(name, opts = {})
      @scoped_state.guards.push(name, Guard.new(name: name, blocking: opts.fetch(:blocking, true)))
    end
  end
end
