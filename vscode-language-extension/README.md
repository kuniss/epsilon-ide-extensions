# Epsilon EAG VS Code Language Extension

This is the VS Code language extension "epsilon-eag" for the grammar specifcation lanaguage of Epsilon Extended Affix Grammars.

The language server has been development using the Xtext language framework.

## Features

Currrently the following features are supported:
* syntax highlighting (please install the themes Epsilon EAG (Light) or Epsilon EAG (Dark) for best coloring)
* folding
* auto bracket closing and insertion
* syntax and reference errors for meta and hyper nonterminal
* nonterminal navigation
* autocompletion
* auto-indentation

## Requirements

No specific requirements needed.

## Extension Settings

No extension settings available, yet.

## Known Issues

Currently, it is possible to create specifcations with invalid Affix definitions as they are not checked semantically.

The specifations cannot be executed, currently. There is no parser and evaluator generator backend implemented yet.

## Release Notes

See [CHANGELOG](vscode-language-extension/CHANGELOG.md)
