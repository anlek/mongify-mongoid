require 'spec_helper'

describe Mongify::Mongoid::Generator do
  context "Instance Methods" do
    context "process" do

      let(:translation_file) { "spec/files/translation.rb" }
      subject(:generator) { Mongify::Mongoid::Generator.new(translation_file) }

      it "processes successfully" do
        subject.should_receive(:generate_root_models)
        subject.should_receive(:generate_embedded_models)
        subject.should_receive(:generate_polymorphic_models)
        subject.should_receive(:write_models_to_file)

        subject.process
      end

      context "file doesnt exists" do
        subject { Mongify::Mongoid::Generator.new("/my/awesome/file.ext") }

        it "should raise FileNotFound exception" do
          expect { subject.process }.to raise_error(Mongify::Mongoid::FileNotFound)
        end
      end
    end
  end

end
