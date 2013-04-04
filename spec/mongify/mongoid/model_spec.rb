require 'spec_helper'

describe Mongify::Mongoid::Model do
  before do
    @model = Mongify::Mongoid::Model.new("users")
    @associated = "preferences"
  end

  context "add_field" do
    before { @model.add_field("name", "String") }

    subject { @model }
    it { should have_field("name").of_type("String") }
  end

  Mongify::Mongoid::Model::RELATIONSHIPS.each do |relation|
    context "add_#{relation}_relation" do
      before { @model.send("add_#{relation}_relation", @associated) }

      subject { @model }
      it { should have_relationship(relation).on(@associated) }
    end
  end
end
