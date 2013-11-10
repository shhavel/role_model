require 'spec_helper'

describe RoleModel::Roles do

  let(:valid_roles) do
    {
      foo: 0,
      bar: 1,
      baz: 2,
      quux: 3
    }
  end
  let(:array) { [:foo, :bar] }
  let(:callback_method) { double('AFakeCallbackMethod') }
  subject { RoleModel::Roles.new(array, valid_roles, callback_method) }

  it { should include(:foo, :bar) }
  it { should respond_to(:each) }

  describe "#<<" do
    it "should add the given element to the callback method by re-assigning all roles" do
      callback_method.should_receive(:call).with(array_including(:foo, :bar, :baz))
      subject << :baz
    end
  end

  describe "#add" do
    it "should add the given element to the model_instance.roles by re-assigning all roles" do
      callback_method.should_receive(:call).with(array_including(:foo, :bar, :baz))
      subject.add(:baz)
    end
  end

  describe "#merge" do
    it "should add the given enum to the model_instance.roles by re-assigning all roles" do
      callback_method.stub(:call)
      callback_method.should_receive(:call).with(array_including(:foo, :bar, :baz, :quux))
      subject.merge([:baz, :quux])
    end
  end

  describe "#delete" do
    it "should delete the given element to the model_instance.roles by re-assigning all roles" do
      callback_method.should_receive(:call).with(subject)
      subject.delete :foo
      subject.should_not include(:foo)
    end
  end

  describe "#subtract" do
    it "should remove the given enum to the model_instance.roles by re-assigning all roles" do
      callback_method.stub(:call)
      callback_method.should_receive(:call).with(subject)
      subject.subtract([:foo, :bar])
      subject.should have(0).roles
    end
  end
end
