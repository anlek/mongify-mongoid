require 'spec_helper'

describe Mongify::Mongoid::CLI::Command::Worker do
  let(:translation_file){ "spec/files/translation.rb" }
  let(:output_folder) { "spec/files/tmp" }
  subject(:worker) { Mongify::Mongoid::CLI::Command::Worker.new(translation_file) }

  before(:each) do
    allow_any_instance_of(Mongify::Mongoid::Printer).to receive(:write)
  end

  let(:view) do
    view = double("View")
    allow(view).to receive(:output)
    allow(view).to receive(:report_success)
    view
  end

  context "default output file" do
    it "should be called path + models" do
      allow(FileUtils).to receive(:mkdir_p)
      allow_any_instance_of(Mongify::Mongoid::Generator).to receive(:process)
      worker.output_folder.should == File.join(Dir.pwd, "models")
    end
  end

  context "translation file" do
    it "raises an error if not passed" do
      lambda { Mongify::Mongoid::CLI::Command::Worker.new().execute(view) }.should raise_error(Mongify::Mongoid::TranslationFileNotFound)
    end
    it "raises an error if file doesn't exist" do
      lambda { Mongify::Mongoid::CLI::Command::Worker.new("missing/translation.rb").execute(view) }.should raise_error(Mongify::Mongoid::TranslationFileNotFound)
    end
  end

  context "output folder" do
    it "raises an error if folder exist" do
      lambda { Mongify::Mongoid::CLI::Command::Worker.new(translation_file, output_folder).execute(view) }.should raise_error(Mongify::Mongoid::OverwritingFolder)
    end
    it "doesn't raise error if overwrite is true" do
      expect { Mongify::Mongoid::CLI::Command::Worker.new(translation_file, output_folder, :overwrite => true).execute(view) }.to_not raise_error
    end
  end

end
