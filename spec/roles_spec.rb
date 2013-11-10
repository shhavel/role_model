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
  let(:array)           { [:foo, :bar] }
  let(:callback_method) { double('AFakeCallbackMethod') }
  subject { RoleModel::Roles.new(array, valid_roles, callback_method) }

  it { should respond_to(:each) }

  describe '#initialize' do
    context 'with bitmask' do
      let(:bitmask) { 2**valid_roles[:foo] + 2**valid_roles[:bar] }
      subject { RoleModel::Roles.new(bitmask, valid_roles) }

      it { should include(:foo, :bar) }
    end

    context 'with array' do
      subject { RoleModel::Roles.new(array, valid_roles) }

      it { should include(:foo, :bar) }
    end

    context 'with other Roles model' do
      let(:other_model) { RoleModel::Roles.new([:foo, :bar], valid_roles) }
      subject { RoleModel::Roles.new(other_model, valid_roles) }

      it { should include(:foo, :bar) }
    end
  end

  describe 'sanitation of roles' do
    context 'on #initialize' do
      subject { RoleModel::Roles.new([:xyz], valid_roles) }

      it 'prevents from adding not valid roles' do
      end
    end
    context 'on #add' do
      subject { RoleModel::Roles.new([], valid_roles) }

      it 'prevents from adding not valid roles' do
        subject << :xyz
      end
    end

    after do
      subject.should_not include(:xyz)
    end
  end

  describe '#bitmask' do
    it 'should return a bitmask based on :valid_roles' do
      bitmask = 2**valid_roles[:foo] + 2**valid_roles[:bar]
      subject.bitmask.should eq(bitmask)
    end
  end

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
