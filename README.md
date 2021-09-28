[![](https://img.shields.io/github/v/release/fischerscode/tagger)](https://github.com/fischerscode/tagger/releases/latest)
[![](https://img.shields.io/github/license/fischerscode/tagger)](https://github.com/fischerscode/tagger/blob/master/LICENSE)

You can use Tagger either as a [command line tool](#tagger-as-a-command-line-tool) or an [GitHub Action](#tagger-v01-action)


# Tagger V0.1 Action
This action automatically moves semantic tags. When providing the tag '1.2.3', '1' and '1.2' will be moved to the position of '1.2.3'.

This action is mend to be run when ever a release has been created.

## Usage
```yaml
name: move tags

on:
  release:
    types:
      - "created"

jobs:
  tags:
    runs-on: ubuntu-latest
    steps:
      # You have to check out your repo first.
      - uses: actions/checkout@v2
      - uses: fischerscode/tagger@v0.1
        with:
          # The prefix of the semantic tags.
          # Default: ''
          prefix: v

          # The new tag. Other tags will be moved to this position.
          # If present, the leading 'refs/tags/' will be removed.
          # ${{ github.ref }}
          tag: 
```

# Tagger as a command line tool

Prebuilt executables can be found [here](https://github.com/fischerscode/tagger/releases/latest).

## Usage:
```
Automatically move semantic tags. When providing the tag '1.2.3', '1' and '1.2' will be moved to the position of '1.2.3'.

Usage: tagger <command> [arguments]

Global options:
-h, --help    Print this usage information.

Available commands:
  move   Move the tags.

Run "tagger help <command>" for more information about a command.
```