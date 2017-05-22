require_relative 'pipeline_specification'

module StateMachine
  module Guard
    attr_reader :name, :blocking

    def initialize(name:, blocking:)
      @name = name
      @blocking = blocking
    end

    def required?(subject)
      raise NoMethodError.new('Guards must implement #required?')
    end

    def self.included(base)
      base.send :extend, ClassMethods
    end

    def pipelines
      pipeline_spec.pipelines
    end

    def pipeline_spec
      class << self
        return pipeline_spec if pipeline_spec
      end
      
      c = self.class
      until c.pipeline_spec || !(c.include? Guard)
        c = c.superclass
      end
      c.pipeline_spec
    end

    module ClassMethods
      attr_reader :pipeline_spec

      def pipelines(&specification)
        @pipeline_spec = PipelineSpecification.new(&specification)
      end
    end
  end
end
