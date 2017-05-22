require 'ostruct'
require_relative 'state_machine/specification'
require_relative 'state_machine/policy'

module StateMachine
  def self.included(base)
    base.send :extend, ClassMethods
  end

  def can_advance_state?
    return false unless next_state
    can_move_to_state?(next_state.name)
  end

  def can_move_to_state?(name)
    required_guards(name).none?
  end

  def required_guards(state_name)
    spec.states[state_name].guards.values.select do |guard|
      guard.blocking && guard.policy_class.new(self).required?
    end
  end

  def current_state
    @current_state || spec.initial_state
  end

  def events
    @events ||= []
  end

  def halted?
    @halted
  end

  def halted_because
    @halted_because
  end

  def halt(reason = nil)
    @halted_because = reason
    @halted = true
  end

  def next_state
    current_state.next_state
  end

  def process_event!(name, *args)
    event = current_state.events[name]

    from = current_state
    to = spec.states[event.transitions_to]
    raise Error.new("Event[#{name}]'s transitions_to[#{event.transitions_to}]' is not a declared state") if to.nil?

    @halted = false
    @halted_because = nil

    halt("Guard requirements are not met: #{required_guards(event.transitions_to).map(&:name)}") unless can_move_to_state?(event.transitions_to)
    return false if halted?

    puts "1. Before Transition (#{from}, #{to}, #{name}, #{args})"
    return false if halted?
    puts "2. Run Action #{event.name}"
    return false if halted?
    puts "3. On Transition (#{from}, #{to}, #{name}, #{args})"
    puts "4. On Exit (#{from}, #{to}, #{name}, #{args})"
    puts "5. Persist current state and event"
    @current_state = to
    events << OpenStruct.new(name: name, created_at: Time.now)
    puts "6. On Entry (#{from}, #{to}, #{name}, #{args})"
    puts "7. After Transition (#{from}, #{to}, #{name}, #{args})"
    current_state.to_s
  end

  def spec
    class << self
      return workflow_spec if workflow_spec
    end

    c = self.class
    until c.workflow_spec || !(c.include? Workflow)
      c = c.superclass
    end
    c.workflow_spec
  end

  module ClassMethods
    attr_reader :workflow_spec

    def workflow(&specification)
      assign_workflow Specification.new(&specification)
    end

    private

    def assign_workflow(specification)
      @workflow_spec = specification

      @workflow_spec.states.values.each do |state|
        state_name = state.name
        module_eval do
          define_method "#{state_name}?" do
            state_name == current_state.name
          end
        end

        state.events.values.each do |event|
          event_name = event.name
          module_eval do
            define_method "#{event_name}!".to_sym do |*args|
              process_event!(event_name, *args)
            end

            define_method "can_#{event_name}?" do
              event = current_state.events[event_name]
              !!event && can_move_to_state?(event.transitions_to)
            end
          end
        end
      end
    end
  end
end
