# IDE Extensions and Plugins for the Epsilon EAG Specification Language

This project contains several IDE extensions and plugins for the Extended Affix Grammar specification language. This closed calculus was originally designed and researched at the TU Berlin.

The extension and plugins has been implemented using the Xtext language framework. However, this represents only the EAG language frontend. The language backend with parser generator and evaluator generator is provided by the Gamma Compiler Generator trough [linkrope's Gamma repository](https://github.com/linkrope/gamma).

If configured, the front implemented here is able to subsequently run the "real" generator to either generate in the final compiler in [D](https://dlang.org) or to report errors and warnings from the generator run. The generator comes embedded into the VS Code extension respectively the Eclipse plugin.

## List of Supported Extensions

* [VS Code language extension](https://marketplace.visualstudio.com/items?itemName=Grammarcraft.epsilon-eag)
* [VS Code themes (dark and light)](https://marketplace.visualstudio.com/search?term=grammarcraft&target=VSCode&category=Themes&sortBy=Relevance)
* a [VS code extension pack](https://marketplace.visualstudio.com/items?itemName=Grammarcraft.epsilon-eag-extension-pack) to subsume all extension above
* Gitpod and Theia support via the VS Code extensions available from [Eclipse Open VSX Registry](https://open-vsx.org/?search=grammarcraft&category=&sortBy=relevance&sortOrder=desc)
* Eclipse plugin (update site: [https://www.grammarcraft.de/gamma/](https://www.grammarcraft.de/gamma/))
* Web editor (not really used anywhere)
