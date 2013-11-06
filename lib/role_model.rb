require 'role_model/implementation'
require 'role_model/class_methods'
require 'role_model/roles'

module RoleModel

  INHERITABLE_CLASS_ATTRIBUTES = [:roles_registry]

  include Implementation

  def self.included(base) # :nodoc:
    base.extend ClassMethods
    base.class_eval do
      class << self
        attr_accessor(*::RoleModel::INHERITABLE_CLASS_ATTRIBUTES)

        def valid_roles
          r = roles_registry.values.inject({}) { |m, v| m.merge!(v); m }
          RoleModel::Util.valid_roles(r)
        end
      end
      self.roles_registry = {}
    end
  end

  module Util
    class << self
      def normalize_roles(roles)
        r = roles.flatten
        r.first.is_a?(RoleModel::Roles) ? r.first.to_a : r
      end

      def sanitize_roles(roles, roles_registry)
        roles.to_a.map { |role| Array(role) }.flatten.map(&:to_sym) & valid_roles(roles_registry)
      end

      def build_roles_mask(roles, roles_registry)
        roles.map { |role| 2**roles_registry[role] }.inject(0, :+)
      end

      # Returns {RoleModel::Roles} set of role names, taken from ROLES and calculated
      # from role_mask
      #
      # Params:
      #   - role_mask {Integer} to transform to roles
      def role_mask_to_roles(role_mask, roles_registry, method)
        roles = roles_registry.reject { |name, id|
          ((role_mask || 0) & 2**id).zero?
        }.keys
        RoleModel::Roles.new(roles, method)
      end

      def valid_roles(roles_registry)
        roles_registry.keys
      end
    end
  end
end
