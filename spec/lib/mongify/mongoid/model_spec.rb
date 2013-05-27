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
    it "doesn't add the id column" do
      model.add_field("id", "integer")
      model.should_not have_field("id")
    end
    it "doesn't add ignored columns" do
      model.add_field("first_name", "String", {ignore: true})
      model.should_not have_field("first_name")
    end
    it "renames fields" do
      model.add_field("sur_name", "String", {rename_to: "last_name"})
      model.should_not have_field("sur_name")
      model.should have_field("last_name")
    end
    it "doesn't add a reference columns" do
      model.add_field("user_id", "integer", {references: 'users'})
      model.should_not have_field("user_id")
    end
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
