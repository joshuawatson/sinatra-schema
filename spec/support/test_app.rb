class TestApp < Sinatra::Base
  register Sinatra::Schema

  get "/regular" do
    "hi"
  end

  resource("/accounts") do |res|
    res.description "An account represents an individual signed up to use the service"

    res.property.text :email,
      description: "unique email address of account",
      example:     "username@example.com",
      format:      "email"

    res.link(:get) do |link|
      link.title       "Info"
      link.rel         "self"
      link.description "Info for account"
      link.action do
        { email: "foo@bar.com" }
      end
    end

    res.link(:post) do |link|
      link.title         "Create"
      link.rel           "create"
      link.description   "Create a new account"
      link.property.text :email
      link.action do |params|
        { email: params[:email] }
      end
    end
  end
end
