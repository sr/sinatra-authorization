require "test/unit"
require "rack/test"
require "sinatra/base"
require "sinatra/authorization"

class AuthorizationApp < Sinatra::Default
  set :environment, :test

  get "/" do
    login_required

    "Welcome in protected zone"
  end

  def authorize(username, password)
    username == "user" && password = "test"
  end

  def authorization_realm
    "Move on"
  end
end

class SinatraAuthorizationTest < Test::Unit::TestCase
  def setup
    @session = Rack::Test::Session.new(AuthorizationApp)
  end

  def basic_auth(user="user", password="test")
    credentials = ["#{user}:#{password}"].pack("m*")

    { "HTTP_AUTHORIZATION" => "Basic #{credentials}" }
  end

  def test_authorized_with_right_credentials
    @session.get "/", {}, basic_auth
    assert_equal 200, @session.last_response.status
    assert_equal "Welcome in protected zone", @session.last_response.body
  end

  def test_sets_REMOTE_USER
    # TODO
  end

  def test_unauthorized_without_credentials
    @session.get "/"
    assert_equal 401, @session.last_response.status
  end

  def test_unauthorized_with_wrong_credentials
    @session.get "/", {}, basic_auth("evil", "wrong")
    assert_equal 401, @session.last_response.status
  end

  def test_realm
    @session.get "/"
    assert_equal %Q(Basic realm="Move on"), @session.last_response["WWW-Authenticate"]
  end

  def test_no_auth
    @session.get "/", {}, { "HTTP_AUTHORIZATION" => "Foo bar" }
    assert_equal 400, @session.last_response.status
  end
end
