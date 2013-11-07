require 'set'

module RoleModel
  class Roles < ::Set # :nodoc:
    attr_reader :setter_method, :valid_roles

    def initialize(roles_or_bitmask, valid_roles, setter_method=nil)
      @valid_roles   = valid_roles
      @setter_method = setter_method

      if roles_or_bitmask.is_a?(Integer)
        super(bitmask_to_roles(roles_or_bitmask))
      else
        normalized = normalize_roles(roles_or_bitmask)
        sanitized  = sanitize_roles(normalized)
        super(sanitized)
      end
    end

    def add(role)
      roles = super
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

    def sanitize_roles(roles)
      roles.to_a.map { |role| Array(role) }.flatten.map(&:to_sym) & valid_roles.keys.map(&:to_sym)
    end
  end
end
