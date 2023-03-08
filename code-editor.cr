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
  parser.banner = "Usage: #{PROGRAM_NAME} [options]"
  parser.on "-m STR", "--model STR", "ID of the model to use" do |v|
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
  parser.on "-i STR", "--instruction STR", "The instruction that tells the model how to edit the prompt." do |v|
    data.instruction = v.to_s
  end
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

data.input = ARGF.gets_to_end
STDERR.puts data.pretty_inspect if debug_flag

spinner_text = (data.instruction.empty? ? "(None)" : data.instruction).colorize(:green)
sp = Spin.new(0.2, Spinner::Charset[:pulsate2], spinner_text , output: STDERR)
sp.start

url = "https://api.openai.com/v1/edits"
api_key = ENV["OPENAI_API_KEY"]
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
