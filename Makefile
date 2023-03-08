# Makefile for compiling code-editor.cr

# Variables
BIN = code-editor
SRC = code-editor.cr

# Targets
all: $(BIN)

$(BIN): $(SRC)
	crystal build --release $(SRC) -o $(BIN)

clean:
	rm -f $(BIN)

.PHONY: all clean
