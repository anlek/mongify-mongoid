require 'spec_helper'

describe Mongify::Mongoid::Model do
  subject(:model) { Mongify::Mongoid::Model.new(:table_name => "users", :class_name => "User") }
  
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
    it "raises error if field is unkown" do
      expect { model.add_field("user_id", 'limb') }.to raise_error(
                  Mongify::Mongoid::InvalidField, 
                  "Unkown field type limb for user_id in #{model.class_name}")
    end
  end

  it "should find relation" do
    model.add_relation(Mongify::Mongoid::Model::Relation::BELONGS_TO, "accounts")
    model.add_relation(Mongify::Mongoid::Model::Relation::HAS_MANY, "posts")
    r = model.send(:find_relation_by, "accounts")
    r.association.should == "account"
    r.name.should == Mongify::Mongoid::Model::Relation::BELONGS_TO
  end

  it "should delete relation" do
    model.add_relation(Mongify::Mongoid::Model::Relation::BELONGS_TO, "accounts")
    model.add_relation(Mongify::Mongoid::Model::Relation::HAS_MANY, "posts")
    model.send(:delete_relation_for, "accounts")
    model.should have(1).relation
  end

  describe "Timestamps" do
    it "doesn't at created_at field" do
      model.add_field("created_at", "Datetime")
      model.should have(0).fields
    end
    it "doesn't at updated_at field" do
      model.add_field("updated_at", "Datetime")
      model.should have(0).fields
    end

    it "has a created_at timestamp" do
      model.should_not have_created_at_timestamp
      model.add_field("created_at", "Datetime")
      model.should have_created_at_timestamp
    end

    it "has a updated_at timestamp" do
      model.should_not have_updated_at_timestamp
      model.add_field("updated_at", "Datetime")
      model.should have_updated_at_timestamp
    end

    it "has timestamps" do
      model.should_not have_timestamps
      model.add_field("updated_at", "Datetime")
      model.should have_timestamps
    end

    it "has both timestamps" do
      model.should_not have_both_timestamps
      model.add_field("created_at", "Datetime")
      model.add_field("updated_at", "Datetime")
      model.should have_both_timestamps
    end

    it "doesn't add ignored timestamps" do
      model.add_field("created_at", "Datetime", ignore: true)
      model.should_not have_timestamps
    end
  end

  context "polymorphic name" do
    before(:each) do
      model.polymorphic_as = "userable"
    end
    it "should match" do
      model.send("polymorphic_field?", "userable_id").should be_true
      model.send("polymorphic_field?", "userable_type").should be_true
    end
    it "doesn't match" do
      model.send("polymorphic_field?", "user_name").should be_false
      model.send("polymorphic_field?", "userable_other").should be_false
    end

  end

  describe "add_relation" do
    let(:associated) { "preferences" }
    Mongify::Mongoid::Model::Relation::VALID_RELATIONS.each do |relation|
      context relation do
        before { model.add_relation(relation, associated) }
        it { should have_relation(relation).for_association(associated) }
      end
    end

    context "embedded relations overpower relational relations" do
      let(:association){"comments"}
      it "works" do
        model.add_relation(Mongify::Mongoid::Model::Relation::HAS_MANY, association)
        model.add_relation(Mongify::Mongoid::Model::Relation::EMBEDS_MANY, association)
        model.relations.should have(1).relation
        relation = model.relations.first
        relation.name.should == Mongify::Mongoid::Model::Relation::EMBEDS_MANY
        relation.association = association
      end

      it "works with belongs_to as well" do
        model.add_relation(Mongify::Mongoid::Model::Relation::BELONGS_TO, association.singularize)
        model.add_relation(Mongify::Mongoid::Model::Relation::EMBEDDED_IN, association)
        model.relations.should have(1).relation
        relation = model.relations.first
        relation.name.should == Mongify::Mongoid::Model::Relation::EMBEDDED_IN
        relation.association = association
      end

      it "doesn't delete embedded" do
        model.add_relation(Mongify::Mongoid::Model::Relation::EMBEDS_MANY, association)
        model.add_relation(Mongify::Mongoid::Model::Relation::HAS_MANY, association)
        model.relations.should have(1).relation
      end
      
    end
  end
end
