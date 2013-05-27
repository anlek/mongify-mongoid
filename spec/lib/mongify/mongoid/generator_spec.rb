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
        let(:table) { stub(name: 'users', columns: [], polymorphic?: false) }
        it "should build model" do
          subject.models.should be_empty
          subject.send("build_model", table)
          subject.should have(1).model
          model = subject.models[table.name.to_sym]
          model.table_name.should == table.name
        end
      end
      context "process_fields" do
        let(:table) { stub(name: 'users', columns: [], ignored?: false, polymorphic?: false) }
        before(:each) do
          table.stub(:columns).and_return([stub(name: "first_name", type: "string", options: {}), stub(name: "last_name", type: "string", options:{})])  
          subject.translation.stub(:all_tables).and_return([table])
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
        let(:table) { stub(name: 'preferences', columns: [stub(name: "Email", type:"string")], polymorphic?: false) }
        let(:parent_model){ Mongify::Mongoid::Model.new(:table_name => "users", :class_name => "User")}
        before(:each) do
          table.stub(:embed_in).and_return('users')
          table.stub(:embedded_as_object?).and_return(true)
          subject.generate_models
          generator.models[parent_model.table_name.to_sym] = parent_model
          @model = subject.send("extract_embedded_relations", table)
        end

        context "model relations" do
          it "should add embedded_in relations" do
            @model.should have_relation(Mongify::Mongoid::Model::Relation::EMBEDDED_IN).for_association(parent_model.table_name)
          end
        end
        context "parent model relations" do
          it "should add embeds_one " do
            parent_model.should have_relation(Mongify::Mongoid::Model::Relation::EMBEDS_ONE).for_association(@model.table_name)
          end
        end
      end

      context "polymorphic tables" do
        let(:table) { stub(name: 'users', columns: [], ignored?: false, polymorphic?: false) }
        let(:polymorphic_table){ stub(name: 'notes', columns: [], ignored?: false, polymorphic?: true, polymorphic_as: "notable") }
        before(:each) do
          table.stub(:columns).and_return([stub(name: "first_name", type: "string", options: {}), stub(name: "last_name", type: "string", options:{})])
          tables = [table, polymorphic_table]
          tables.each do |_table|
            subject.translation.stub(:find).with(_table.name).and_return(_table)
          end
          
          subject.translation.stub(:all_tables).and_return(tables)
          subject.generate_models
        end
        it "should have model" do
          model = subject.find_model(polymorphic_table.name)
          model.should_not be_nil
          model.should be_polymorphic
        end

        it "should not add polymorphic fields" do
          subject.process_fields
          model = subject.find_model(polymorphic_table.name)
          model.should_not have_relation(:belongs_to)
        end
      end

      context "generate_fields_for" do
        let(:model) {generator.send(:build_model, stub(name: "users", polymorphic?: false))}
        let(:parent_model) {generator.send(:build_model, stub(name: "accounts", polymorphic?: false))}
        let(:table) {stub(name: "users", columns: [stub(name: "account_id", type: "id", options: {'references' => "accounts"})], polymorphic?: false)}
        before(:each) do
          model #generate via rspec
          parent_model #generate via rspec
          generator.translation.stub(:find).with(model.table_name).and_return(table)
        end
        it "adds correctly" do
          generator.send(:generate_fields_for, model, table)
          model.should have_relation(Mongify::Mongoid::Model::Relation::BELONGS_TO).for_association("account")
          parent_model.should have_relation(Mongify::Mongoid::Model::Relation::HAS_MANY).for_association("users")
        end
      end

      after(:all) do
        FileUtils.rm  Dir["#{output_dir}/*.rb"]
      end
    end
  end
end
