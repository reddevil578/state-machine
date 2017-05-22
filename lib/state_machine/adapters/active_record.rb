module StateMachine
  module Adapter
    module ActiveRecord
      module InstanceMethods
        def load_current_state
          read_attribute :current_state
        end

        def persist_state_and_event(from, to, event_name)
          puts "Persist current state and event ACTIVE RECORD ADAPTER"
          @current_state = to
          update_column :current_state, new_value
          events << OpenStruct.new(name: event_name, created_at: Time.now)
        end

        private

        def write_initial_state
          write_attribute :current_state, current_state.to_s
        end
      end

      module ClassMethods
      end

      def self.included(base)
        base.send :extend, Adapter::ActiveRecord::ClassMethods
        base.send :include, Adapter::ActiveRecord::InstanceMethods
        base.before_validation :write_initial_state
      end
    end
  end
end
