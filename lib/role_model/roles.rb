require 'set'

module RoleModel
  class Roles < ::Set # :nodoc:
    attr_reader :setter_method

    def initialize(roles, setter_method)
      super(roles)
      @setter_method = setter_method
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
  end
end
