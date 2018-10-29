require "http"
require "open3"

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
        resend_code(par[:response_url], par[:text])
      end
    end
  end

  def resend_timeout(url, code)
    resend_obj(url, {
      response_type: "in_channel",
      text: "Execution timed out while running '#{code}'.",
    })
  end

  def resend_code(url, code)
    result = rkt(url, code)
    resend_obj(url, {
      response_type: "in_channel",
      text: "Result of running '#{code}':",
      attachments: [
        {
          text: result
        }
      ]
    })
  end

  def resend_obj(url, obj)
    HTTP.post(url, json: obj)
  end

  def rkt(url, code)
    f = File.open((@job+=1).to_s, "w")
    f.puts("#lang safe")
    f.puts(code)
    f.close
    res = {}
    begin
      Timeout::timeout(20) do
        Timeout::timeout(15) do
          stdout, stderr, status = Open3.capture3("racket -S lib -S /app/.apt/usr/share/racket/collects -t #{f.path}")
          res = {stdout: stdout, stderr: stderr, status: status}
        end
      end
    rescue
      File.delete(f.path)
      resend_timeout(url, code)
      Thread::current.kill
    end

    File.delete(f.path)
    if res[:status] == 0
      return res[:stdout]
    else
      return "ERROR\n#{res[:stderr]}"
    end
  end

end
