# openai-edit
# https://platform.openai.com/docs/api-reference/edits

require "option_parser"
require "http/client"
require "json"
require "spinner"
require "colorize"

PROGRAM_VERSION = "0.1.0"
debug_flag = false

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

# Parse command line options
OptionParser.parse do |parser|
  parser.banner = "Usage: #{PROGRAM_NAME} [options]"
  parser.on "-n INT", "How many edits to generate for the input and instruction." do |v|
    data.n = v.to_i? || (STDERR.puts "Error: Invalid number of edits"; exit 1)
  end
  parser.on "-t Float", "--temperature Float", "Sampling temperature between 0 and 2 affects randomness of output." do |v|
    data.temperature = v.to_f? || (STDERR.puts "Error: Invalid temperature"; exit 1)
  end
  parser.on "-p Float", "--top_p Float", "Nucleus sampling considers top_p probability mass for token selection." do |v|
    data.top_p = v.to_f? || (STDERR.puts "Error: Invalid top_p"; exit 1)
  end
  parser.on "-d", "--debug", "Print request data" do
    debug_flag = true
  end
  parser.on "-v", "--version", "Show version" do
    puts PROGRAM_VERSION
    exit
  end
  parser.on("-h", "--help", "Show help") { puts parser; exit }
end

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

def send_chat_request(url, data, headers, debug_flag)
  STDERR.puts data.pretty_inspect.colorize(:dark_gray) if debug_flag
  spinner_text = "ChatGPT".colorize(:green)
  sp = Spin.new(0.2, Spinner::Charset[:pulsate2], spinner_text, output: STDERR)
  sp.start
  response = HTTP::Client.post(url, body: data.to_json, headers: headers)
  sp.stop
  response
end

loop do
  msg = get_input("> ")
  break if msg.empty?
  data.messages << {"role" => "user", "content" => msg}

  response = send_chat_request(url, data, headers, debug_flag)
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
