require 'spec_helper'

describe Mongify::Mongoid::Generator do
  context "Instance Methods" do
    context "process" do

      let(:translation_file) { "spec/files/translation.rb" }
      let(:output_dir){File.expand_path('../../../files/tmp', File.dirname(__FILE__))}
      subject(:generator) { Mongify::Mongoid::Generator.new(translation_file, output_dir) }

      it "processes successfully" do
        subject.should_receive(:generate_root_models)
        subject.should_receive(:generate_embedded_models)
        subject.should_receive(:generate_polymorphic_models)
        subject.should_receive(:write_models_to_file)

        subject.process
      end

      context "file doesnt exists" do
        subject { Mongify::Mongoid::Generator.new("/my/awesome/file.ext", output_dir) }

        it "should raise FileNotFound exception" do
          expect { subject.process }.to raise_error(Mongify::Mongoid::FileNotFound)
        end
      end

      context "root_models" do
        let(:table) { stub(name: 'user', columns: []) }
        it "should build model" do
          subject.models.should be_empty
          subject.send("build_model", table)
          subject.should have(1).model
          model = subject.models[table.name.to_sym]
          model.table_name.should == table.name
        end

        context "fields" do
          before(:each) do
            table.stub(:columns).and_return([stub(name: "first_name", type: "string"), stub(name: "last_name", type: "string")])
          end
          it "should add fields" do
            subject.send("generate_root_model", table)
            model = subject.models[table.name.to_sym]
            model.should have(2).fields
          end
        end
      end

      context "embedded_model" do
        let(:table) { stub(name: 'preferences', columns: []) }
        let(:parent_model){ Mongify::Mongoid::Model.new(:table_name => "users", :class_name => "User")}
        before(:each) do
          table.stub(:embed_in).and_return('users')
          table.stub(:embedded_as_object?).and_return(true)
          generator.models[parent_model.table_name.to_sym] = parent_model
          @model = subject.send("generate_embedded_model", table)
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
            relation.association.should == @model.table_name
          end
        end
        
      end
    end
  end

end
