require 'spec_helper'

describe Mongify::Mongoid::Model::Field do
  subject(:field){ Mongify::Mongoid::Model::Field.new("first_name", "String") }
  context "types" do
    context "validation" do
      it "doesn't raise error when valid value" do
        expect { Mongify::Mongoid::Model::Field.new("first_name", "String") }.to_not raise_error
      end
      it "does raise error on invalid value" do
        expect { Mongify::Mongoid::Model::Field.new("first_name", "Limb") }.to raise_error(Mongify::Mongoid::InvalidField)
      end
    end

    context "decimal" do
      it "works" do
        subject = Mongify::Mongoid::Model::Field.new("money", "Decimal")
        expect(subject.type).to eq "String"
      end
    end

    context "translation" do
      [:array, :bigdecimal, :decimal, :boolean, :date, :datetime, :float, :hash, :integer, :objectid, :binary, :range, :regexp, :string, :symbol, :time, :timewithzone].each do |type|
        it "for #{type} works" do
          field.send(:translate_type, type).should == Mongify::Mongoid::Model::Field::TRANSLATION_TYPES[type]
        end
      end
      it "for Text is String" do
        field.send(:translate_type, 'Text').should == "String"
      end
      it "uses original name if no translation was found" do
        type = "Limb"
        field.send(:translate_type, type).should == type
      end
    end

  end
end