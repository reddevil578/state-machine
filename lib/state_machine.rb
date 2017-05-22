require 'ostruct'
require_relative 'state_machine/specification'
require_relative 'state_machine/guard'
require_relative 'state_machine/adapters/active_record'

module StateMachine
  module InstanceMethods
    def can_advance_state?
      return false unless next_state
      can_move_to_state?(next_state.name)
    end

    def can_move_to_state?(name)
      required_guards(name).none?
    end

    def required_guards(state_name)
      spec.states[state_name].guards.values.select do |guard|
        guard.blocking && guard.required?(self)
      end
    end

    def current_state
      loaded_state = load_current_state
      res = spec.states[loaded_state.to_sym] if loaded_state
      res || spec.initial_state
    end

    def load_current_state
      @current_state if instance_variable_defined? :@current_state
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

    def persist_state_and_event(from, to, event_name)
      puts "Persist current state and event"
      @current_state = to
      events << OpenStruct.new(name: event_name, created_at: Time.now)
    end

    def run_action(event_name, *args)
      send(event_name, *args) if respond_to?(event_name)
    end

    def run_on_entry(state, prior_state, event_name, *args)
      callback_method = "on_#{state}_entry"
      send(callback_method, prior_state, event_name, *args) if respond_to?(callback_method)
    end

    def run_on_exit(state, new_state, event_name, *args)
      callback_method = "on_#{state}_exit"
      send(callback_method, new_state, event_name, *args) if respond_to?(callback_method)
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

      run_action(name, *args)
      return false if halted?

      run_on_exit(from, to, name, *args)

      persist_state_and_event(from, to, name)

      run_on_entry(to, from, name, *args)

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

  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
    if const_defined?(:ActiveRecord) && base < ActiveRecord::Base
      base.send :include, Adapter::ActiveRecord
    end
  end
end
