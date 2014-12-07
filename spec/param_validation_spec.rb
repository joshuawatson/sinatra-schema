require "spec_helper"

describe Sinatra::Schema::ParamValidation do
  before do
    @rack_app = Sinatra.new do
      helpers Sinatra::Schema::ParamValidation
      post("/") do
        params = MultiJson.decode(request.body.read)
        validate_params!(indifferent_params(params), $properties)
        "ok"
      end
    end
  end

  it "errors out on unexpected params" do
    $properties = {}
    assert_raises(Sinatra::Schema::BadParams) do
      post "/", MultiJson.encode(foo: "bar")
    end
  end

  it "errors out on missing params" do
    $properties = { foo: Sinatra::Schema::Definition.new(type: "string") }
    assert_raises(Sinatra::Schema::BadParams) do
      post "/", "{}"
    end
  end

  it "errors out on wrong format" do
    $properties = { bool: Sinatra::Schema::Definition.new(type: "boolean") }
    assert_raises(Sinatra::Schema::BadParams) do
      post "/", MultiJson.encode(bool: "omg")
    end
  end

  it "supports nested params" do
    $properties = { foo: { bar: Sinatra::Schema::Definition.new(type: "boolean") }}
    assert_raises(Sinatra::Schema::BadParams) do
      post "/", MultiJson.encode(foo: { bar: "omg" })
      puts last_response.body
    end
  end
end
