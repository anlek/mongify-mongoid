require 'spec_helper'

describe Mongify::Mongoid::CLI::Command::Worker do
  let(:translation_file){ "spec/files/translation.rb" }
  let(:output_folder) { "spec/files/tmp" }
  subject(:worker) { Mongify::Mongoid::CLI::Command::Worker.new(translation_file) }
  
  before(:each) do
    Mongify::Mongoid::Printer.any_instance.stub(:write)
  end
  
  let(:view) {
    view = stub("View")
    view.stub(:output)
    view.stub(:report_success)
    view
  }

  context "default output file" do
    it "should be called path + models" do
      FileUtils.stub(:mkdir_p)
      Mongify::Mongoid::Generator.any_instance.stub(:process)
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
      lambda { Mongify::Mongoid::CLI::Command::Worker.new(translation_file, output_folder, :overwrite => true).execute(view) }.should_not raise_error(Mongify::Mongoid::OverwritingFolder)
    end
  end
  
end
