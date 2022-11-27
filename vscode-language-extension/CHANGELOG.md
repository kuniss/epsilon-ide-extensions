# Change Log

## 2.2.0

- removed ":." from auto closing pairs to avoid it is automatically added at affix domain definitions when typing ":" 

## 2.1.1
- solved a build extension publishing problem   

## 2.1.0
- added new grammar specification language feature allowing to declare white spaces on grammar level

## 2.0.3
- corrected OpenVSX publishing task to get it published finally

## 2.0.2
- ensure publishing to OpenVSX does not repackage the extension as node modules are left out that way  

## 2.0.1
- no changes, just new publishing via GitHub actions

## 2.0.0
- [Experimental] Linux only: incorporated execution of Gamma compiler generator which 
    - adds according problem markers in case errors or warnings are reported by the compiler generator; markers are correct regarding the position determined by the compiler generator (requires Gamma compiler generator with '--offset' argument support)
    - generates D source code for specified compilers and compiles them to an executable if a D compiler is installed 
    - can be configured via property 'eag.compileGenerator.executable' pointing to an executable path, as well property 'eag.compilerGenerator.targetDir' defining where the compilers are generated too

## 1.3.1
- added syntax highlighting support for backtick strings (was forgotten to be added in 1.3.0...)
- corrected the meta non-terminal alternative snippet to get rid of a VS code snippet warning notification

## 1.3.0
- added backtick string support as this will come with Gamma, the successor of Epsilon; backtick strings are not evaluated for escaped characters (like \n) and are in that sense "raw" strings

## 1.2.0
- added sophisticated snippets for rules, alternatives, affix parameters and EBNF constructs
- corrected comment toggling to the new C-like syntax
- license file packaged to fullfill OpenVSX legal requirements

## 1.1.1
- no changes (published together with other extensions as part of the Epsilon EAG extension pack, other parts of the pack may have changes)

## 1.1.0
- does not resolve undefined nonterminals as cross references from other Epsilon files anymore and thus creates proper linkage errors (solves GitHub issue [#1](https://github.com/kuniss/epsilon-ide-extensions/issues/1))

## 1.0.0
- syntax adaptations for the Epsilon language according to changes made by @linkrope to the new lexer in the Epsilon root project, including
    - enabled Unicode for nonterminals
    - switched from # to ! as "unequal" predicate
    - switched to C-like comment style
    - allowing comments inside affix definitions
- breaks backward compatibility in the Epsilon language due to changed comment style and changed "unequal" predicate sign

## 0.0.9
- try to publish to Open VSX via travis-ci

## 0.0.8
- added the .eag and .epsilon as supported language extension to the Xtext generated Epsilon language server

## 0.0.7
- added .eag as supported language extension

## 0.0.6
- no changes

## 0.0.5
- corrected repository links in the readme 

## 0.0.4
- release build logic corrected

## 0.0.3
- Prepared for building and publishing with travis-ci.org

## 0.0.2
- Initial release to VS Marketplace, functionally equal to 0.0.1

## 0.0.1
- Initial release