class ApplicationController < ActionController::API
  def initialize()
    @client_id = ENV.fetch("CLIENT_ID")
    @client_secret = ENV.fetch("CLIENT_SECRET")
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
    response = HTTP.post(url, params: {
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
    par = 
    code = params.permit(:text)[:text]
    result = rkt(code)
    render json: {
      response_type: "in_channel",
      text: "The result of running '" + code + "':",
      attachments: [
        {
          text: result
        }
      ]
    }
  end

  def rkt(code)
    `racket -S /app/.apt/usr/share/racket/collects -e '#{code}'`.chomp
  end
end
