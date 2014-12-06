require "spec_helper"

describe Sinatra::Schema::DSL::Definitions do
  let(:resource) { Sinatra::Schema::Resource.new(path: "/foobar") }
  let(:dsl)      { described_class.new(resource, options) }
  let(:options)  { Hash.new }
  let(:root)     { Sinatra::Schema::Root.instance }

  it "adds a string definition to the resource" do
    dsl.text(:foobar)
    assert_equal 1, resource.defs.size
    assert_equal "string", resource.defs[:foobar].type
  end

  it "adds a boolean definition to the resource" do
    dsl.bool(:foobar)
    assert_equal 1, resource.defs.size
    assert_equal "boolean", resource.defs[:foobar].type
  end

  describe "#ref" do
    let(:definition) { Sinatra::Schema::Definition.new }
    before { options[:serialize] = true }

    it "adds a reference to another definition in the resource" do
      resource.defs[:foobar] = definition
      dsl.ref :foobar
      assert_equal 1, resource.defs.size
      assert_equal 1, resource.properties.size
    end

    it "adds a reference to a definition in a different resource" do
      other = Sinatra::Schema::Resource.new(path: "/others")
      root.add_resource(other)
      other.defs[:foobar] = definition
      dsl.ref "other/foobar"
      assert_equal 1, other.defs.size
      assert_equal 1, resource.properties.size
    end
  end
end
