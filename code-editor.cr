# openai-edit

require "option_parser"
require "http/client"
require "json"
require "spinner"
require "colorize"

VERSION = "0.1.0"
debug_flag = false

struct PostData
  include JSON::Serializable
  property model : String
  property input : String
  property instruction : String
  property n : Int32
  property temperature : Float64
  property top_p : Float64

  def initialize
    @model = "text-davinci-edit-001"
    @input = ""
    @instruction = ""
    @n = 1
    @temperature = 0.5
    @top_p = 1.0
  end
end

data = PostData.new

# Parse command line options
OptionParser.parse do |parser|
  parser.banner = "Usage: openai-edit [options]"
  parser.on "-m STR", "--model STR", "model to use" do |v|
    case v
    when "text", "text-davinci-edit-001"
      data.model = "text-davinci-edit-001"
    when "code", "code-davinci-edit-001"
      data.model = "code-davinci-edit-001"
    else
      STDERR.puts "Error: Invalid model"
      exit 1
    end
  end
  parser.on "-i STR", "--instruction STR", "tells the model how to edit" do |v|
    data.instruction = v.to_s
  end
  parser.on "-n INT", "number of edits" do |v|
    data.n = v.to_i? || (STDERR.puts "Error: Invalid number of edits"; exit 1)
  end
  parser.on "-t INT", "--temperature INT" do |v|
    data.temperature = v.to_f? || (STDERR.puts "Error: Invalid temperature"; exit 1)
  end
  parser.on "-p INT", "--top_p INT" do |v|
    data.top_p = v.to_f? || (STDERR.puts "Error: Invalid top_p"; exit 1)
  end
  parser.on "-d", "--debug", "Print request data" do
    debug_flag = true
  end
  parser.on "-v", "--version", "Show version" do
    puts VERSION
    exit
  end
  parser.on("-h", "--help", "Show help") { puts parser; exit }
end

data.input = ARGF.gets_to_end
STDERR.puts data.pretty_inspect if debug_flag

sp = Spin.new(0.2, Spinner::Charset[:pulsate2], data.instruction.colorize(:green), output: STDERR)
sp.start

url = "https://api.openai.com/v1/edits"
api_key = ENV["OPENAI_ACCESS_TOKEN"]
headers = HTTP::Headers{
  "Authorization" => "Bearer #{api_key}",
  "Content-Type"  => "application/json",
}
response = HTTP::Client.post(url, body: data.to_json, headers: headers)

sp.stop

if response.status.success?
  response_data = JSON.parse(response.body)
  puts response_data["choices"][0]["text"]
else
  STDERR.puts "Error: #{response.status_code} #{response.status}".colorize(:yellow).mode(:bold)
end
