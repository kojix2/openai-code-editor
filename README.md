# OpenAI code-editor

Command-line tools to perform code/text editing using the [OpenAI API](https://platform.openai.com/docs/api-reference/edits). (`text-davinci-edit-001`, `code-davinci-edit-001`)

<div align="center"><img src="https://user-images.githubusercontent.com/5798442/223654401-4423f7cb-4149-4186-b313-840e2af00432.png"></div>

To use this tool, an OpenAI Access Token is required.

Please Set `ENV["OPENAI_API_KEY"]`

## Install

```sh
make
sudo make install
```

## Usage

```sh
code-editor -i "Add documenations" foo.rb
```

This tool overwrites files. It is recommended to use it in a Git-controlled directory.

## Options

```
Usage: code-editor [options]
    -m STR, --model STR              ID of the model to use
    -T, --text                       Use text model
    -C, --code                       Use code model
    -i STR, --instruction STR        The instruction that tells the model how to edit the prompt.
    -n INT                           How many edits to generate for the input and instruction.
    -t Float, --temperature Float    Sampling temperature between 0 and 2 affects randomness of output.
    -p Float, --top_p Float          Nucleus sampling considers top_p probability mass for token selection.
    -o [FILE], --output [FILE]       Output file name
    -d, --debug                      Print request data
    -v, --version                    Show version
    -h, --help                       Show help
```

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
