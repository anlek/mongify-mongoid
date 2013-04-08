require 'spec_helper'

describe Mongify::Mongoid::Relation do
  describe "VALID_RELATIONS" do
    subject { Mongify::Mongoid::Relation::VALID_RELATIONS }

    it { should =~ %w(embeds_one embeds_many embedded_in has_one has_many has_and_belongs_to_many belongs_to) }
  end

  describe "initialize" do
    context "invalid relation name" do
      it "should raise InvalidRelation error" do
        expect {
          @relation = Mongify::Mongoid::Relation.new(:brother, "user", {})
        }.to raise_error, Mongify::Mongoid::InvalidRelation
      end
    end

    context "valid relation name" do
      before do
        @relation = Mongify::Mongoid::Relation.new(:embeds_one, "user", {})
      end

      subject { @relation }
      its(:name) { should == "embeds_one" }
      its(:association) { should == "user" }
      its(:options) { should == {} }
    end
  end
end
