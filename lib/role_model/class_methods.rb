module RoleModel
  module ClassMethods
    def inherited(subclass) # :nodoc:
      ::RoleModel::INHERITABLE_CLASS_ATTRIBUTES.each do |attribute|
        instance_var = "@#{attribute}"
        subclass.instance_variable_set(instance_var, instance_variable_get(instance_var))
      end
      super
    end

    # set the bitmask attribute role assignments will be stored in
    def roles_attribute(name, options={})
      attribute_setter = options[:setter] || name
      roles_set        = options[:roles]  || []
      callbacks        = [options[:callbacks]].flatten.compact

      unless callbacks.empty?
        callbacks.each do |callback|
          self.send(callback, attribute_setter, name)
        end
      end

      roles(roles_set, attribute_name: attribute_setter)
      define_roles_methods(attribute_name: name, attribute_setter: attribute_setter)
    end

    protected

    # :call-seq:
    #   roles(:role_1, ..., :role_n)
    #   roles('role_1', ..., 'role_n')
    #   roles([:role_1, ..., :role_n])
    #   roles(['role_1', ..., 'role_n'])
    #
    # declare valid roles
    def roles(roles, opts)
      raise 'Attribute name must be set' unless
        attribute_name = opts[:attribute_name]

      if roles.is_a?(Hash)
        roles_registry = roles.dup
      elsif
        roles_registry = roles.flatten.map(&:to_sym).
          each_with_index.inject({}) do |memo, (role, index)|
            memo[role] = index
            memo
          end
      end

      @roles_registry[attribute_name] = roles_registry
    end

    private

    def define_roles_methods(options)
      raise 'Name of roles attribute must be set.' unless
        attribute_name = options[:attribute_name]
      raise 'Name of roles mask setter method must be set.' unless
        attribute_setter = options[:attribute_setter]

      class_eval <<-RUBY, __FILE__, __LINE__+1
        # Returns RoleModel::Roles based on role_mask.
        # To get raw array of roles, append to_a:
        #
        #   staff.roles.to_a #=> [:role_1, :role_n]
        def #{attribute_setter}
          roles_registry  = self.class.roles_registry[:#{attribute_setter}]
          setter_method   = self.method('#{attribute_setter}=')
          RoleModel::Roles.new(#{attribute_name}, roles_registry, setter_method)
        end

        # Applies {Array} or {RoleModel::Roles} set of roles to role_mask.
        def #{attribute_setter}=(*roles)
          roles_registry  = self.class.roles_registry[:#{attribute_setter}]
          self.#{attribute_name} = RoleModel::Roles.new(roles, roles_registry).bitmask
        end
      RUBY
    end
  end
end
