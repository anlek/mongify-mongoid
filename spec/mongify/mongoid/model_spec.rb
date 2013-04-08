require 'spec_helper'

describe Mongify::Mongoid::Model do
  before do
    @model = Mongify::Mongoid::Model.new(:table_name => "users", :class_name => "User")
    @associated = "preferences"
  end

  describe "initialize" do
    before do
      @model = Mongify::Mongoid::Model.new(:class_name => "User", :table_name => :users)
    end

    subject { @model }
    its(:class_name) { should == "User" }
    its(:table_name) { should == "users" }
  end

  describe "add_field" do
    before { @model.add_field("name", "String") }

    subject { @model }
    it { should have_field("name").of_type("String") }
  end

  describe "add_relation" do
    Mongify::Mongoid::Relation::VALID_RELATIONS.each do |relation|
      context relation do
        before { @model.add_relation(relation, @associated) }

        subject { @model }
        it { should have_relation(relation).for_associated(@associated) }
      end
    end
  end
end
