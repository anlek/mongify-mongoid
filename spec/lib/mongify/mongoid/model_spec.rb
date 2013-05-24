require 'spec_helper'

describe Mongify::Mongoid::Model do
  subject(:model) { Mongify::Mongoid::Model.new(:table_name => "users", :class_name => "User") }
  let(:associated) { "preferences" }
  
  describe "initialize" do
    its(:class_name) { should == "User" }
    its(:table_name) { should == "users" }
  end

  describe "add_field" do
    before(:each) { model.add_field("name", "String") }
    it { should have_field("name").of_type("String") }
  end

  describe "add_relation" do
    Mongify::Mongoid::Model::Relation::VALID_RELATIONS.each do |relation|
      context relation do
        before { model.add_relation(relation, associated) }

        subject { model }
        it { should have_relation(relation).for_association(associated) }
      end
    end
  end
end
