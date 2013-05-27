require 'spec_helper'

describe Mongify::Mongoid::Generator do
  context "Instance Methods" do
    context "process" do

      let(:translation_file) { "spec/files/translation.rb" }
      let(:output_dir){File.expand_path('../../../files/tmp', File.dirname(__FILE__))}
      subject(:generator) { Mongify::Mongoid::Generator.new(translation_file, output_dir) }

      it "is successful" do
        subject.should_receive(:generate_models)
        subject.should_receive(:process_fields)
        subject.should_receive(:generate_embedded_relations)
        subject.should_receive(:write_models_to_file)

        subject.process
      end

      context "file doesnt exists" do
        subject { Mongify::Mongoid::Generator.new("/my/awesome/file.ext", output_dir) }

        it "should raise FileNotFound exception" do
          expect { subject.process }.to raise_error(Mongify::Mongoid::FileNotFound)
        end
      end

      context "generate_models" do
        let(:table) { stub(name: 'users', columns: []) }
        it "should build model" do
          subject.models.should be_empty
          subject.send("build_model", table)
          subject.should have(1).model
          model = subject.models[table.name.to_sym]
          model.table_name.should == table.name
        end
      end
      context "process_fields" do
        let(:table) { stub(name: 'users', columns: []) }
        before(:each) do
          table.stub(:columns).and_return([stub(name: "first_name", type: "string", options: {}), stub(name: "last_name", type: "string", options:{})])
          subject.send(:translation).stub(:find).with(table.name).and_return(table)
          subject.send(:translation).stub(:tables).and_return([table])
          subject.generate_models
        end
        it "works" do
          subject.send(:translation).should_receive(:find).with(table.name).and_return(table)
          subject.process_fields
          model = subject.find_model(table.name)
          model.should have(2).fields
        end
      end

      context "embedded_relations" do
        let(:table) { stub(name: 'preferences', columns: [stub(name: "Email", type:"string")]) }
        let(:parent_model){ Mongify::Mongoid::Model.new(:table_name => "users", :class_name => "User")}
        before(:each) do
          table.stub(:embed_in).and_return('users')
          table.stub(:embedded_as_object?).and_return(true)
          subject.send("generate_models")
          generator.models[parent_model.table_name.to_sym] = parent_model
          @model = subject.send("extract_embedded_relations", table)
        end

        context "model relations" do
          it "should add embedded_in relations" do
            relation = @model.relations.first
            relation.name.should == "embedded_in"
            relation.association.should == parent_model.table_name
          end
        end
        context "parent model relations" do
          it "should add embeds_one " do
            relation = parent_model.relations.first
            relation.name.should == "embeds_one"
            relation.association.should == @model.table_name.singularize
          end
        end
      end
      after(:all) do
        FileUtils.rm  Dir["#{output_dir}/*.rb"]
      end
    end
  end
end
