require 'set'

module RoleModel
  class Roles < ::Set # :nodoc:
    attr_reader :setter_method, :valid_roles

    def initialize(roles_or_bitmask, valid_roles, setter_method=nil)
      @valid_roles       = valid_roles
      @valid_roles_array = valid_roles.keys.map(&:to_sym)

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
      roles = super if valid_role?(role)
      setter_method.call(roles) if setter_method
      self
    end
    alias_method :<<, :add

    def delete(role)
      roles = super
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

    def normalize_roles(roles)
      r = (roles || []).flatten
      r.first.is_a?(RoleModel::Roles) ? r.first.to_a : r
    end

    def valid_role?(role)
      @valid_roles_array.include?(role.to_sym)
    end
  end
end
