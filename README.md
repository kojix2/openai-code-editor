# OpenAI scripts

Command-line tools to perform code/text editing using the [OpenAI API](https://platform.openai.com/docs/api-reference/edits).

To use this tool, an OpenAI Access Token is required.
Please Set `ENV["OPENAI_ACCESS_TOKEN"]`

## Install

```
make
sudo make install
```

## Usage

```
code-editor -i "Add documenations" foo.rb
cat foo.rb | code-editor -i "Add documentations"
```

```
code-editor -i "Add documenations" foo.rb > bar.rb
meld foo.rb bar.rb
```

## Options

```
Usage: code-editor [options]
    -m STR, --model STR              ID of the model to use
    -i STR, --instruction STR        The instruction that tells the model how to edit the prompt.
    -n INT                           How many edits to generate for the input and instruction.
    -t Float, --temperature Float    Sampling temperature between 0 and 2 affects randomness of output.
    -p Float, --top_p Float          Nucleus sampling considers top_p probability mass for token selection.
    -d, --debug                      Print request data
    -v, --version                    Show version
    -h, --help                       Show help
```



## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).