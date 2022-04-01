module Proto
  @brain ||= Module.new {
    ##
    # @param [Proto] proto
    #  An object who has included the Proto
    #  module.
    #
    # @param [String, to_s] property
    #  The name of the property.
    #
    # @param [Object, BasicObject]
    #  The value of the property.
    #
    # @return [void]
    # @api private
    def self.define_property!(proto, property, value)
      table = unbox_table(proto)
      table[property] = value
      return if method_defined?(proto, "#{property}=")
      define_method!(proto, property) { proto[property] }
      define_method!(proto, "#{property}=") { proto[property] = _1 }
    end

    ##
    # @param [Proto] proto
    #  An object who has included the Proto
    #  module.
    #
    # @return [Hash]
    #  Returns the internal lookup table used by
    #  *proto*.
    def self.unbox_table(proto)
      Module
        .instance_method(:instance_variable_get)
        .bind_call(proto, :@table)
    end

    ##
    # @param [Proto] proto
    #  An object who has included the Proto
    #  module.
    #
    # @param [String, Symbol] method
    #  The name of a method.
    #
    # @param [Object, BasicObject] *args
    #  A variable number of arguments for *method*.
    #
    # @param [Proc] &b
    #  An optional block for *method*.
    #
    # @return [Object, BasicObject]
    #  Returns the return value of the method call.
    def self.call_method(proto, method, *args, &b)
      Module
        .instance_method(:__send__)
        .bind_call(proto, method, *args, &b)
    end

    ##
    # @param [Proto] proto
    #  An object who has included the Proto
    #  module.
    #
    # @param [String, Symbol]
    #  The name of the method.
    #
    # @param [Proc] &b
    #  The method's body.
    #
    # @return [void]
    def self.define_method!(proto, method, &b)
      Module
        .instance_method(:define_singleton_method)
        .bind_call(proto, method, &b)
    end

    ##
    # @param [Proto] proto
    #  An object who has included the Proto
    #  module.
    #
    # @param [Symbol, String] method
    #  The name of the method.
    #
    # @return [Method]
    #  Returns a Method object for *method*.
    def self.method(proto, method)
      Module
        .instance_method(:method)
        .bind_call(proto, method)
    end

    # @param [Proto] proto
    #  An object who has included the Proto
    #  module.
    #
    # @param [Symbol, String] method
    #  The name of the method.
    #
    # @return [String, nil]
    #  Returns the path to the file that defined *method*.
    def self.method_file(proto, method)
      method(proto, method).source_location.dig(0)
    end

    ##
    # @param [Proto] proto
    #  An object who has included the Proto
    #  module.
    #
    # @param [Symbol, String] method
    #  The name of the method
    #
    # @return [Boolean]
    #  Returns true when *method* is defined on self.
    def self.method_defined?(proto, method)
      (class << proto; self; end).method_defined?(method, false)
    end

    ##
    # @param [Proto] proto
    #  An object who has included the Proto
    #  module.
    #
    # @param [String] property
    #  The property.
    #
    # @return [Boolean]
    #  Returns true when *property* is a member of *proto*.
    def self.property?(proto, property)
      unbox_table(proto).key?(property.to_s)
    end

    ##
    # Deletes a property from *proto*
    #
    # @param [String] property
    #  The property to delete.
    #
    # @return [void]
    def self.delete(proto, property)
      property = property.to_s
      if property?(proto, property)
        unbox_table(proto).delete(property)
      else
        return if method_defined?(proto, property) &&
                  method_file(proto, property) == __FILE__
        define_method!(proto, property) { proto[property] }
      end
    end
  }

  ##
  # The purpose of the Proto.Kernel method is to provide a
  # separate namespace for methods that would otherwise be
  # defined as private instance methods on the Proto module.
  #
  # @return [Module]
  #  Returns an anonymous module
  #
  # @api private
  def self.brain
    @brain
  end
end
