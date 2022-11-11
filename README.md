# Overview

Implementing support for features like autocomplete, goto definition, or documentation on hover for programming is a significant effort. However, comparing to other language like java, python, javascript and c, language server protocol implementation for lisp language are just made in a vacuum. [Geiser](https://gitlab.com/emacs-geiser), [racket language server](https://github.com/theia-ide/racket-language-server) etc., their works are all based on `repl`(Read-Eval-Print Loop) instead of programming. For example, if a programmer was coding on a programming project, in which the codes are not fully runable, [Geiser](https://gitlab.com/emacs-geiser) or any others would only complete top-level binding identifiers listed by `environment-symbols` procedure (for [Chez](https://cisco.github.io/ChezScheme/)). Which means for local bindings and unaccomplished codes, though making effort for programming is supposed of the importance mostly, [Geiser](https://gitlab.com/emacs-geiser) and its counterparts help nothing. Familiar cases occur with goto definition and many other functionalities.

A primary cause is, for scheme and other lisp dialects, their abundant data sets and flexible control structures raise program analysis a big challenge. For example, [scheme don't have commonly acknowledged extension](https://stackoverflow.com/questions/36240629/whats-the-proper-scheme-file-extension). As for extensions SS, and SCM, most programmers suppose their codes are writing for a running environment and don't provide any library information. Although with [Akku](https://akkuscm.org/) and [Snow](http://snow-fort.org/), SLS and SLD files can establish a project on a stable library framework, `involve`, `load` and many other procedures which maintain dynamic library linkages make static code analysis telling less.

This package is a language server protocol implementation helping scheme programming. It provides completion, definition and will provide many other functionalities. These functionalities are established on static code analysis with [r6rs standard](http://www.r6rs.org/) and some obvious rules for unaccomplished codes. This package itself and related libraries are published or going to be published with [Akku](https://akkuscm.org/), which is a package manager for Scheme. 

This package also has been tested with [Chez Scheme](https://cisco.github.io/ChezScheme/) versions 9.4 and 9.5.

Your donation will make this world better. Also, you can issue your advice and I might implement if it was available.

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/paypalme/ufo5260987423/10)

# Status 

This project is still in early development, so you may run into rough edges with any of the features. The following list shows the status of various features.

## Features
1. Top-level and local identifiers binding completion.
2. Goto definition.
3. Compatible with package manager: Akku.

## TODOs

4. Fully compatible with r6rs standard.
5. File modification notification and corresponding index changing.
6. Cross-platform Parallel indexing.
7. Macro expanding.
8. Code eval.
9. Code diagnostic.
10. Fully r6rs compability.
11. Add cross-language semantic supporting.
12. File-change notification to improve workspace refreshing.

# Test
> bash test.sh
