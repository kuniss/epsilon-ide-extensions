# Epsilon EAG VS Code Language Extension

This is the VS Code language extension "epsilon-eag" for the grammar specifcation language of Epsilon Extended Affix Grammars.

The language server has been development using the Xtext language framework.

Synatx highlighting support has been developed using the syntax hightlighting "grammar" online editor [*Iro*](https://eeyo.io/iro/) capable to issue "grammars" for Textmate, Atom, Sublime and others. For details see Chris Ainsley's [article](https://medium.com/@model_train/creating-universal-syntax-highlighters-with-iro-549501698fd2) on it.

In case of Textmate, *Iro* creates .plist files. As it is more convinient and more common to use Textmate grammars in JSON format, the .plist file has been transformed using the service http://json2plist.sinaapp.com/.

The *Iro* file for syntax hightlighting definitions may be found at [Epsilon.iro](https://github.com/kuniss/epsilon-ide-extensions/blob/master/vscode-language-extension/Epsilon.iro).

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

Non Linux systems: Currently, it is possible to create specifcations with invalid Affix definitions as they are not checked semantically.

Non Linux systems: The specifations cannot be executed, currently. There is no parser and evaluator generator backend implemented yet.

## Release Notes

See [CHANGELOG](vscode-language-extension/CHANGELOG.md)
