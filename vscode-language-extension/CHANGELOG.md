# Change Log

## 1.1.1-SNAPSHOT
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