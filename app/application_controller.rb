require "http"
require "open3"

class ApplicationController < ActionController::API
  def initialize()
    @client_id = ENV.fetch("CLIENT_ID")
    @client_secret = ENV.fetch("CLIENT_SECRET")
    @@job = 0
  end

  def info
    render html: "This is the API for Racket Helper."
  end

  def index
    render html: "Thanks for installing Racket Helper on your slack server."
  end

  def auth
    code = params.permit(:code)[:code]
    if not code
      render html: "No code given."
      return
    end
    url = "https://slack.com/api/oauth.access"
    response = HTTP.post(url, json: {
      client_id: @client_id,
      client_secret: @client_secret,
      code: code
    })

    json = JSON.parse(response.to_s)
    if json["ok"]
      render html: "Successfully added Racket Helper to your slack server."
      return
    else
      render html: "There was an error adding the application to your slack server: " + json["error"]
      return
    end
  end

  def api
    p params
    par = params.permit(:text, :response_url, :user, :user_id)
    text = par[:text]
    text.gsub!(/[”“]/, '"')
    text.gsub!(/[‘’]/, "'")
    response_url = par[:response_url]
    user_name = par[:user_name]
    user_id = par[:user_id]
    render json: {
      response_type: "in_channel",
      text: "Running code. Please wait.",
      attachments: [
        {
          text: text
        }
      ]
    }

    exec = Execution.create(user_id: user_id, user_name: user_name, command: text, response_url: response_url)

    Thread.new do
      Rails.application.executor.wrap do
        exec.resend_code
      end
    end
  end

end
