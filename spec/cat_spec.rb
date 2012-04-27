require 'sandbox'

describe Sandbox do

  before(:each) do
    Sandbox.cleanup!
    Sandbox.constants.should == []
  end

  describe "#cleanup!" do
    it "removes all the classes defined by Sandbox" do
      Sandbox.add_class("Foo")
      constants = Sandbox.created_classes
      Sandbox.cleanup!
      Sandbox.created_classes.collect(&:to_s).should == ["Foo"]
      constants.each do |const|
        Sandbox.constants.should_not include(const)
      end
    end
  end

  describe "#add_class" do
    it "creates a class namedspaced under Sandbox" do
      Sandbox.add_class("Foo")
      Sandbox.constants.collect(&:to_s).should include("Foo")
    end

    describe "when you pass a double-colon delimited string" do
      it "creates nested subclasses" do
        Sandbox.add_class("Bar::Wood")
        Sandbox.constants.collect(&:to_s).should include("Bar")
        Sandbox::Bar.constants.collect(&:to_s).should include("Wood")
      end
    end
  end

  describe "#add_attributes" do
    it "adds getter and setter methods to the class" do
      Sandbox.add_class("Soap::Ivory::Powdered")
      Sandbox.add_attributes("Soap::Ivory", "id", :title)
      ivory = Sandbox::Soap::Ivory.new
      ivory.id = 10
      ivory.title = "Toweling off"

      ivory.id.should == 10
      ivory.title.should == "Toweling off"
    end

    it "adds an initialize method to set attributes with a hash" do
      Sandbox.add_class("Soap::Ivory::Powdered")
      Sandbox.add_attributes("Soap::Ivory", "id", :title)
      ivory = Sandbox::Soap::Ivory.new(:id => 10, :title => "Toweling off")

      ivory.id.should == 10
      ivory.title.should == "Toweling off"
    end
  end

  describe "#add_method" do
    context "passing a proc" do
      it "adds an instance method" do
        Sandbox.add_class("Soap::Ivory::Liquid")
        Sandbox.add_method("Soap::Ivory", :imbroglio, lambda { 'he said she said' })

        ivory = Sandbox::Soap::Ivory.new
        ivory.imbroglio.should == 'he said she said'
      end
    end

    context "passing a block" do
      it "adds an instance method" do
        Sandbox.add_class("Soap::Ivory::Liquid")
        Sandbox.add_method("Soap::Ivory", :imbroglio) { 'he said she said' }

        ivory = Sandbox::Soap::Ivory.new
        ivory.imbroglio.should == 'he said she said'
      end
    end
  end

  describe "#add_class_method" do
    context "passing a proc" do
      it "adds a class method" do
        Sandbox.add_class("Foo")
        Sandbox.add_class_method("Foo", "bar", lambda { "foo foo" })

        Sandbox::Foo.bar.should == "foo foo"
      end
    end

    context "passing a block" do
      it "adds a class method" do
        Sandbox.add_class("Foo")
        Sandbox.add_class_method("Foo", "bar") { "foo " * 2 }

        Sandbox::Foo.bar.should == "foo foo "
      end
    end
  end

  describe "setting a subclass on an existing subclass" do
    it "doesn't raise a warning" do
      orig_stderr = $stderr
      $stderr = StringIO.new

      Sandbox.add_class("Foo::Bar")
      Sandbox.add_class("Foo::Babar")

      $stderr.rewind
      $stderr.string.chomp.should == ""
      $stderr = orig_stderr
    end
  end
end
