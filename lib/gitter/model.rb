module Gitter
  module Model

    def self.included base
      base.send :attr_reader, :model
    end

    # evaluate data (string or proc) in context of grid
    def eval data, model = nil
      instance_variable_set :"@model", model
      attributes.each do |name,block|
        instance_variable_set :"@#{name}", instance_eval(&block)
      end

      res = instance_eval &data

      remove_instance_variable :"@model"
      attributes.each do |name,block|
        remove_instance_variable :"@#{name}"
      end

      res
    end

    def attribute name, &block
      self.class.send :attr_reader, name
      attributes[name] = block or raise ArgumentError, "missing block for model #{model}"
    end

    private
    def attributes
      @attributes||={}
    end

  end
end
