# EAG - VS Code Language Extension for Extended Affix Grammar Specifications

This is the VS Code language extension "epsilon-eag" for the grammar specifcation language of Epsilon/Gamma Extended Affix Grammars.

The compiler generator processing these specifications was originally developed under the name *Epsilon* in Oberon-2 and later [migrated to D](https://github.com/linkrope/epsilon).
Afterwards the development was continued in the [*Gamma* project](https://github.com/linkrope/gamma).

The language server has been development using the Xtext language framework to realize name navigation, auto-completion and cross reference resolution. It is backed by the real compiler generator (Linux only yet) which performs deeper semantic checks and code generation on file saving.

Syntax highlighting support has been developed using the syntax hightlighting "grammar" online editor [*Iro*](https://eeyo.io/iro/) capable to issue "grammars" for Textmate, Atom, Sublime and others. For details see Chris Ainsley's [article](https://medium.com/@model_train/creating-universal-syntax-highlighters-with-iro-549501698fd2) on it.

In case of Textmate, *Iro* creates .plist files. As it is more convinient and more common to use Textmate grammars in JSON format, the .plist file has been transformed using the service http://json2plist.sinaapp.com/.

The *Iro* file for syntax hightlighting definitions may be found at [Epsilon.iro](https://github.com/kuniss/epsilon-ide-extensions/blob/master/vscode-language-extension/Epsilon.iro).

## Features

Currrently the following features are supported:
* syntax highlighting (please install the themes Epsilon EAG (Light) or Epsilon EAG (Dark) for best coloring)
* folding
* auto bracket closing and insertion
* syntax and reference errors for meta and hyper nonterminal
* nonterminal navigation
* auto-completion
* auto-indentation
* semantic checks by the real Gamma compiler generator which comes embedded in the extension, with position-correct findings shown in the problem report view (on file saving)
* embedded Gamma compiler generator runs on
  * Windows 64-bit
  * Linux 64-bit
  * MacOS
* source code generation of the target language compiler on file saving (if no errors have been found), available in *build* sub folder
* automatic compiling of the generated compiler D source code with DMD, if installed, available in the *build* sub folder

## Requirements

No specific requirements needed.

But it is recommended to [install DMD D-Lang compiler](https://dlang.org/download.html#dmd) for utilizing the feature of automatically compiling the target language compiler.

## Extension Settings

See VS code settings [Ctr+,], look up for 'eag'.

## Known Issues

The error position of the generated target language compilers are not accurate under circumstances. See [Gamma issue #6](https://github.com/linkrope/gamma/issues/6).

## Release Notes

See [CHANGELOG](vscode-language-extension/CHANGELOG.md)
