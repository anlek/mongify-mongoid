require 'spec_helper'

describe Mongify::Mongoid::Printer do
  let(:output_dir){File.expand_path('../../../files/tmp', File.dirname(__FILE__))}
  subject(:printer){ Mongify::Mongoid::Printer.new([], output_dir) }
  it "should print" do
    expect { printer.print }.to_not raise_error
  end

  context "file output" do
    let(:model){Mongify::Mongoid::Model.new(table_name: "users", class_name: "User")}
    subject(:printer){ Mongify::Mongoid::Printer.new([model], output_dir) }

    context "content" do
      before(:each) do
        printer.stub(:save_file)
      end
      it "should be include a class" do
        output = printer.send(:render_file, model)
        output.should include("class #{model.name}")
      end
      it "should have fields" do
        model.stub(:fields).and_return([Mongify::Mongoid::Model::Field.new("first_name", "String")])
        output = printer.send(:render_file, model)
        output.should include("field :first_name, type: String")
      end

      it "should have relations" do
        model.stub(:relations).and_return([Mongify::Mongoid::Model::Relation.new(:embedded_in, "posts")])
        output = printer.send(:render_file, model)
        output.should include("embedded_in :posts")
      end

      it "should sort relations" do
        model.stub(:relations).and_return([
          Mongify::Mongoid::Model::Relation.new(:embeds_many, "posts"),
          Mongify::Mongoid::Model::Relation.new(:has_many, "comments"),
          Mongify::Mongoid::Model::Relation.new(:embeds_many, "addons"),
          ])
        output = printer.send(:render_file, model)
        output.gsub(/^(\s+)/, "").should include(%q{
embeds_many :posts
embeds_many :addons
has_many :comments})
      end
    end
    

    it "should create a file" do
      printer.print
      Dir["#{output_dir}/*.rb"].count { |file| File.file?(file) }.should == printer.models.count
    end
  end
  after(:each) do
    FileUtils.rm  Dir["#{output_dir}/*.rb"]
  end
end