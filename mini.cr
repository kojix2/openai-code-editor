require "http/client"
require "json"
require "colorize"

struct PostData
  include JSON::Serializable
  property model : String
  property messages : Array(Hash(String, String))
  property temperature : Float64
  property top_p : Float64
  property n : Int32

  def initialize
    @model = "gpt-3.5-turbo"
    @messages = [] of Hash(String, String)
    @n = 1
    @temperature = 1.0
    @top_p = 1.0
  end
end

data = PostData.new

url = "https://api.openai.com/v1/chat/completions"
api_key = ENV["OPENAI_API_KEY"]
headers = HTTP::Headers{
  "Authorization" => "Bearer #{api_key}",
  "Content-Type"  => "application/json",
}

def get_input(prompt)
  print prompt
  STDIN.gets.to_s.chomp
end

def send_chat_request(url, data, headers)
  STDERR.puts data.pretty_inspect.colorize(:dark_gray)
  HTTP::Client.post(url, body: data.to_json, headers: headers)
end

loop do
  msg = get_input("> ")
  break if msg.empty?
  data.messages << {"role" => "user", "content" => msg}

  response = send_chat_request(url, data, headers)
  response_data = JSON.parse(response.body)

  if response.status.success?
    result = response_data["choices"][0]["message"]["content"]
    data.messages << {"role" => "assistant", "content" => result.to_s}
    puts result.colorize(:green)
  else
    STDERR.puts "Error: #{response.status_code} #{response.status}".colorize(:yellow).mode(:bold)
    STDERR.puts response.body.colorize(:yellow)
    exit 1
  end
end

