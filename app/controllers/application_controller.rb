require "http"

class ApplicationController < ActionController::API
  def initialize()
    @client_id = ENV.fetch("CLIENT_ID")
    @client_secret = ENV.fetch("CLIENT_SECRET")
    @job = 0
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
    par = params.permit(:text, :response_url)
    render json: {
      response_type: "ephemeral",
      text: "Running code. Please wait.",
      attachments: [
        {
          text: par[:text]
        }
      ]
    }

    Thread.new do
      Rails.application.executor.wrap do
        resend(par[:text], par[:response_url])
      end
    end
  end

  def resend(code, url)
    result = rkt(code)
    HTTP.post(url, json: {
      response_type: "in_channel",
      text: "Result of running '#{code}':",
      attachments: [
        {
          text: result
        }
      ]
    })
  end

  def rkt(code)
    f = File.open((@job+=1).to_s, "w")
    f.puts("#lang safe")
    f.puts(code)
    f.close
    result = `racket -S lib -S /app/.apt/usr/share/racket/collects -f #{f.path}`.chomp
    File.delete(f.path)
    result
  end

end
