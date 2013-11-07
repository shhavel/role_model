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
      def valid_roles(roles_registry)
        roles_registry.keys
      end
    end
  end
end
