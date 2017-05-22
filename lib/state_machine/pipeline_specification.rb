require 'ostruct'
require_relative 'pipeline'

module StateMachine
  class PipelineSpecification
    attr_accessor :pipelines

    def initialize(&spec)
      @pipelines = {}
      instance_eval(&spec)
    end

    private

    def pipeline(name, &workflows)
      new_pipeline = Pipeline.new(name: name)
      @pipelines[name.to_sym] = new_pipeline
      @scoped_pipeline = new_pipeline
      instance_eval(&workflows)
    end

    def workflow(name, settings = {})
      @scoped_pipeline.workflows << OpenStruct.new(name: name, settings: settings)
    end
  end
end
