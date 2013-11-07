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
          roles_registry.values.inject({}) { |m, v| m.merge!(v); m }.keys
        end
      end
      self.roles_registry = {}
    end
  end
end
