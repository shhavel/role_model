require 'set'

module RoleModel
  class Roles < ::Set # :nodoc:
    attr_reader :setter_method, :valid_roles

    def initialize(roles_or_bitmask, valid_roles, setter_method=nil)
      @valid_roles       = normalize_valid_roles(valid_roles)
      @valid_roles_array = @valid_roles.keys

      if roles_or_bitmask.is_a?(Integer)
        roles_set = bitmask_to_roles(roles_or_bitmask)
      else
        roles_set  = roles_or_bitmask
      end
      super(roles_set)
      # otherwise super will call :add, and :add will call @setter_method
      @setter_method = setter_method
    end

    def add(role)
      role  = role.to_sym
      roles = super if valid_role?(role)
      setter_method.call(roles) if setter_method
      self
    end
    alias_method :<<, :add

    def delete(role)
      role  = role.to_sym
      roles = super(role)
      setter_method.call(roles) if setter_method
      self
    end

    def bitmask
      self.to_a.map { |role| 2**valid_roles[role] }.inject(0, :+)
    end

    private

    def bitmask_to_roles(bitmask)
      valid_roles.reject do |name, id|
          ((bitmask || 0) & 2**id).zero?
      end.keys
    end

    def valid_role?(role)
      @valid_roles_array.include?(role.to_sym)
    end

    def normalize_valid_roles(roles_registry)
      roles_registry.inject({}) do |memo, (role,id)|
        memo[role.to_sym] = id
        memo
      end
    end
  end
end
