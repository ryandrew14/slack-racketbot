class Execution < ApplicationRecord
  def rkt
    f = File.open(id.to_s, "w")
    f.puts("#lang safe")
    f.puts(command)
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
      resend_timeout
      Thread::current.kill
    end

    File.delete(f.path)
    if res[:status] == 0
      return res[:stdout]
    else
      return "ERROR\n#{res[:stderr]}"
    end
  end

  def resend_timeout
    resend_obj({
      response_type: "in_channel",
      text: "Execution timed out while running '#{command}'.",
    })
  end

  def resend_code
    result = rkt
    resend_obj({
      response_type: "in_channel",
      text: "Result:",
      attachments: [
        {
          text: result
        }
      ]
    })
  end

  def resend_obj(obj)
    HTTP.post(response_url, form: obj)
  end
end
