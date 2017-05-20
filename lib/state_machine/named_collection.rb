module StateMachine
  class NamedCollection < Hash
    def [](name)
      super name.to_sym
    end

    def push(name, event)
      key = name.to_sym
      self[key] ||= event
    end
  end
end
