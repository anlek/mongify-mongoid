require 'spec_helper'

describe Mongify::Mongoid::Generator do
  context "Instance Methods" do
    context "process" do
      context "file exists" do

      end

      context "file doesnt exists" do
        subject { Mongify::Mongoid::Generator.new("/my/awesome/file.ext") }

        it "should raise FileNotFound exception" do
          expect {
            subject.process
          }.to raise_error(Mongify::Mongoid::FileNotFound)
        end
      end
    end
  end

  context "Private Methods" do
  end
end