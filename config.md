- [Humac Human Deets](#org19ea609)
- [Ergonomics](#orgfdecd2e)
  - [Better Local Leaders](#org6ec54d3)
  - [Use mouse scroll](#org6337bb1)
  - [lispy vim](#org73d8410)
- [Consistency](#orgcbe28e3)
  - [consistent paths](#org00d844c)
- [Appearance](#org7f80cdc)
  - [Fonts](#org1556a9a)
  - [Theme](#org018a0eb)
  - [Indent](#orga40c35d)
  - [LSP Behaviour](#orge6cf9b5)
- [Languages](#org1fc6b65)
  - [Web](#org06cc1eb)
  - [Go](#orgdd10467)
  - [Vue](#org864ca0c)
- [Org](#org0586042)
  - [Show properties when cycling through subtrees](#org8c25a2b)
  - [ASCII colours on shell results](#orgb9be192)
- [Literate!](#org1d5d058)
  - [SQL](#orgb686a95)
  - [Go](#org09c422e)
  - [Pairing](#org4bfcb1e)
  - [Exporting](#orgd168ca6)
  - [Sane Org Defaults](#org4911799)
  - [Support Big Query](#org08572fb)
- [Snippets](#org07738c1)
  - [org-mode](#org96ae34f)
    - [Blog Property](#orgece52b0)
- [Dashboard](#org76a3931)
  - [Banners](#org6ea8080)
- [user configs](#org15bf9e3)
- [init.el](#org501945e)
  - [Patch for when using emacs 28+](#org9dd9a75)
  - [Doom! block](#org73b79ac)
- [packages.el](#org6a2581d)
  - [ii-packages](#org13860bd)
  - [upstream](#orga8e224e)

[![img](spacemacs-config/banners/img/kubemacs.png)](spacemacs-config/banners/img/kubemacs.png)

<a id="org19ea609"></a>

# Humac Human Deets

On a sharing.io cluster, we should have these two env vars set&#x2026;so we can personalize to the person who started the instance. Otherwise, they&rsquo;re just a friend.

```elisp
(setq user-full-name (if (getenv "GIT_AUTHOR_NAME")
                         (getenv "GIT_AUTHOR_NAME")
                       "ii friend")
      user-mail-address (if (getenv "GIT_COMMIT_EMAIL")
                            (getenv "GIT_COMMIT_EMAIL")
                          "ii*ii.ii"))
```

<a id="orgfdecd2e"></a>

# Ergonomics

<a id="org6ec54d3"></a>

## Better Local Leaders

I got used to using comma as the localleader key, from spacemacs, so i keep it.

```elisp
(setq doom-localleader-key ",")
```

<a id="org6337bb1"></a>

## Use mouse scroll

```elisp
 (defun scroll-up-5-lines ()
    "Scroll up 5 lines"
    (interactive)
    (scroll-up 5))

  (defun scroll-down-5-lines ()
    "Scroll down 5 lines"
    (interactive)
    (scroll-down 5))

  (global-set-key (kbd "<mouse-4>") 'scroll-down-5-lines)
  (global-set-key (kbd "<mouse-5>") 'scroll-up-5-lines)
```

<a id="org73d8410"></a>

## lispy vim

This sets up keybindings for manipuulating parenthesis with slurp and barf when in normal or visual mode.

```elisp
(map!
 :map smartparens-mode-map
 :nv ">" #'sp-forward-slurp-sexp
 :nv "<" #'sp-forward-barf-sexp
 :nv "}" #'sp-backward-barf-sexp
 :nv "{" #'sp-backward-slurp-sexp)
```

<a id="orgcbe28e3"></a>

# Consistency

<a id="org00d844c"></a>

## consistent paths

If you are using a mac, you can have problem with running source blocks or some language support as the shell PATH isn&rsquo;t found in emacs. [exec-path-from-shell](https://github.com/purcell/exec-path-from-shell) is a solution for this.

```elisp
(when (memq window-system '(mac ns x)) (exec-path-from-shell-initialize))
```

<a id="org7f80cdc"></a>

# Appearance

<a id="org1556a9a"></a>

## Fonts

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here ;; are the three important ones:

```elisp
;(setq doom-font (font-spec :family "Source Code Pro" :size 10)
;      ;; )(font-spec :family "Source Code Pro" :size 8 :weight 'semi-light)
;      doom-serif-font (font-spec :family "Source Code Pro" :size 10)
;      doom-variable-pitch-font (font-spec :family "Source Code Pro" :size 10)
;      doom-unicode-font (font-spec :family "Input Mono Narrow" :size 12)
;      doom-big-font (font-spec :family "Source Code Pro" :size 10))
```

<a id="org018a0eb"></a>

## Theme

```elisp
(setq doom-theme 'doom-gruvbox)
```

<a id="orga40c35d"></a>

## Indent

```elisp
(setq standard-indent 2)
```

<a id="orge6cf9b5"></a>

## LSP Behaviour

This brings over the lsp behaviour of spacemacs, so working with code feels consistent across emacs..

```elisp
(use-package! lsp-ui
:config
          (setq lsp-navigation 'both)
          (setq lsp-ui-doc-enable t)
          (setq lsp-ui-doc-position 'top)
          (setq lsp-ui-doc-alignment 'frame)
          (setq lsp-ui-doc-use-childframe t)
          (setq lsp-ui-doc-use-webkit t)
          (setq lsp-ui-doc-delay 0.2)
          (setq lsp-ui-doc-include-signature nil)
          (setq lsp-ui-sideline-show-symbol t)
          (setq lsp-ui-remap-xref-keybindings t)
          (setq lsp-ui-sideline-enable t)
          (setq lsp-prefer-flymake nil)
          (setq lsp-print-io t))
```

<a id="org1fc6b65"></a>

# Languages

<a id="org06cc1eb"></a>

## Web

auto-closing tags works different if you are in a terminal or gui. We want consistent behaviour when editing any sort of web doc. I also like it to create a closing tag when i&rsquo;ve starteed my opening tag, which is auto-close-style 2

```elisp
(setq web-mode-enable-auto-closing t)
(setq-hook! web-mode web-mode-auto-close-style 2)
```

<a id="orgdd10467"></a>

## Go

Go is enabled, with LSP support in our [init.el](init.el). To get it working properly, though, you want to ensure you have all the go dependencies installed on your computer and your GOPATH set. It&rsquo;s recommended you read the doom docs on golang, following all links to ensure your dependencies are up to date. [Go Docs](file:///Users/hh/humacs/doom-emacs/modules/lang/go/README.md)

I&rsquo;ve had inconsistencies with having the GOPATH set on humacs boxes, so if we are in a humacs pod, explicitly set the GOPATH

```elisp
(when (and (getenv "HUMACS_PROFILE") (not (getenv "GOPATH")))
  (setenv "GOPATH" (concat (getenv "HOME") "/go")))
```

<a id="org864ca0c"></a>

## Vue

Tried out vue-mode, but it was causing more problems than benefits and doesn&rsquo;t seem to do much beyond what web-mode plus vue-lsp support would do. So, following [Gene Hack&rsquo;s Blog Post](https://genehack.blog/2020/08/web-mode-eglot-vetur-vuejs-=-happy/), we&rsquo;ll create our own mode, that just inherits all of web-mode and adds lsp. This requires for [vls](https://npmjs.com/vls) to be installed.

```elisp
(define-derived-mode ii-vue-mode web-mode "iiVue"
  "A major mode derived from web-mode, for editing .vue files with LSP support.")
(add-to-list 'auto-mode-alist '("\\.vue\\'" . ii-vue-mode))
(add-hook 'ii-vue-mode-hook #'lsp!)
```

<a id="org0586042"></a>

# Org

Various settings specific to org-mode to satisfy our preferences

<a id="org8c25a2b"></a>

## Show properties when cycling through subtrees

This is an adjustment to the default hook, which hides drawers by default

```elisp
(setq org-cycle-hook
      ' (org-cycle-hide-archived-subtrees
         org-cycle-show-empty-lines
         org-optimize-window-after-visibility-change))
```

<a id="orgb9be192"></a>

## ASCII colours on shell results

```elisp
(defun ek/babel-ansi ()
  (when-let ((beg (org-babel-where-is-src-block-result nil nil)))
    (save-excursion
      (goto-char beg)
      (when (looking-at org-babel-result-regexp)
        (let ((end (org-babel-result-end))
              (ansi-color-context-region nil))
          (ansi-color-apply-on-region beg end))))))
(add-hook 'org-babel-after-execute-hook 'ek/babel-ansi)
```

<a id="org1d5d058"></a>

# Literate!

<a id="orgb686a95"></a>

## SQL

```elisp
(setq org-babel-default-header-args:sql-mode
      '((:results . "replace code")
        (:product . "postgres")
        (:wrap . "SRC example")))
```

<a id="org09c422e"></a>

## Go

```elisp
(setq org-babel-default-header-args:go
      '((:results . "replace code")
        (:wrap . "SRC example")))
```

<a id="org4bfcb1e"></a>

## Pairing

```elisp
(use-package! graphviz-dot-mode)
(use-package! sql)
(use-package! ii-utils)
(use-package! ii-pair)
(after! ii-pair
  (osc52-set-cut-function)
  )
;;(use-package! iterm)
;;(use-package! ob-tmate)
```

<a id="orgd168ca6"></a>

## Exporting

```elisp
(require 'ox-gfm)
```

<a id="org4911799"></a>

## Sane Org Defaults

In addition to the org defaults, we wanna make sure our exports include results, but that we dont&rsquo; try to run all our tamte commands again.

```elisp
(setq org-babel-default-header-args
      '((:session . "none")
        (:results . "replace code")
        (:comments . "org")
        (:exports . "both")
        (:eval . "never-export")
        (:tangle . "no")))

(setq org-babel-default-header-args:shell
      '((:results . "output code verbatim replace")
        (:wrap . "example")))
```

<a id="org08572fb"></a>

## Support Big Query

```elisp
(defun ii-sql-comint-bq (product options &optional buf-name)
  "Create a bq shell in a comint buffer."
  ;; We may have 'options' like database later
  ;; but for the most part, ensure bq command works externally first
  (sql-comint product options buf-name)
  )
(defun ii-sql-bq (&optional buffer)
  "Run bq by Google as an inferior process."
  (interactive "P")
  (sql-product-interactive 'bq buffer)
  )
(after! sql
  (sql-add-product 'bq "Google Big Query"
                   :free-software nil
                   ;; :font-lock 'bqm-font-lock-keywords ; possibly later?
                   ;; :syntax-alist 'bqm-mode-syntax-table ; invalid
                   :prompt-regexp "^[[:alnum:]-]+> "
                   ;; I don't think we have a continuation prompt
                   ;; but org-babel-execute:sql-mode requires it
                   ;; otherwise re-search-forward errors on nil
                   ;; when it requires a string
                   :prompt-cont-regexp "3a83b8c2z93c89889a4c98r2z34"
                   ;; :prompt-length 9 ; can't precalculate this
                   :sqli-program "bq"
                   :sqli-login nil ; probably just need to preauth
                   :sqli-options '("shell" "--quiet" "--format" "pretty")
                   :sqli-comint-func 'ii-sql-comint-bq
                 )
  )
```

<a id="org07738c1"></a>

# Snippets

These are helpful text expanders made with yasnippet

<a id="org96ae34f"></a>

## org-mode

<a id="orgece52b0"></a>

### Blog Property

Creates a property drawer with all the necessary info for our blog.

```snippet
# -*- snippet -*-
# name: blog
# key: <blog
# --
** ${1:Enter Title}
   :PROPERTIES:
   :EXPORT_FILE_NAME:  ${1:$(downcase(replace-regexp-in-string " " "-" yas-text))}
   :EXPORT_DATE: `(format-time-string "%Y-%m-%d")`
   :EXPORT_HUGO_MENU: :menu "main"
   :EXPORT_HUGO_CUSTOM_FRONT_MATTER: :summary "${2:No Summary Provided}"
   :END:
   ${3:"Enter Tags"$(unless yas-modified-p (progn (counsel-org-tag)(kill-whole-line)))}
```

<a id="org76a3931"></a>

# Dashboard

<a id="org6ea8080"></a>

## Banners

```elisp
(setq
      ;; user-banners-dir
      ;; doom-dashboard-banner-file "img/kubemacs.png"
      doom-dashboard-banner-dir (concat humacs-spacemacs-directory  (convert-standard-filename "/banners/"))
      doom-dashboard-banner-file "img/kubemacs.png"
      fancy-splash-image (concat doom-dashboard-banner-dir doom-dashboard-banner-file)
      )
```

<a id="org15bf9e3"></a>

# user configs

Place your user config in

```elisp
(defun pair-or-user-name ()
    "Getenv SHARINGIO_PAIR_NAME if exists, else USER"
  (if (getenv "SHARINGIO_PAIR_USER")
      (getenv "SHARINGIO_PAIR_USER")
    (getenv "USER")))
(setq humacs-doom-user-config (expand-file-name (concat humacs-directory "doom-config/users/" (pair-or-user-name) ".org")))
(if (file-exists-p humacs-doom-user-config)
  (progn
    (org-babel-load-file humacs-doom-user-config)
  )
)
;; once all personal vars are set, reload the theme
(doom/reload-theme)
;; for some reason this isn't loading
;; and doesn't exist an config.org time
;; (doom-dashboard/open) ;; our default screen
```

<a id="org501945e"></a>

# init.el

:header-args:emacs-lisp+ :tangle init.el :header-args:elisp+ :results silent :tangle init.el

<a id="org9dd9a75"></a>

## Patch for when using emacs 28+

```elisp
;; patch to emacs@28.0.50
;; https://www.reddit.com/r/emacs/comments/kqd9wi/changes_in_emacshead2828050_break_many_packages/
(defmacro define-obsolete-function-alias ( obsolete-name current-name
                                           &optional when docstring)
  "Set OBSOLETE-NAME's function definition to CURRENT-NAME and mark it obsolete.
\(define-obsolete-function-alias \\='old-fun \\='new-fun \"22.1\" \"old-fun's doc.\")
is equivalent to the following two lines of code:
\(defalias \\='old-fun \\='new-fun \"old-fun's doc.\")
\(make-obsolete \\='old-fun \\='new-fun \"22.1\")
WHEN should be a string indicating when the function was first
made obsolete, for example a date or a release number.
See the docstrings of `defalias' and `make-obsolete' for more details."
  (declare (doc-string 4)
           (advertised-calling-convention
           ;; New code should always provide the `when' argument
           (obsolete-name current-name when &optional docstring) "23.1"))
  `(progn
     (defalias ,obsolete-name ,current-name ,docstring)
     (make-obsolete ,obsolete-name ,current-name ,when)))
```

<a id="org73b79ac"></a>

## Doom! block

```elisp
(doom! :input
       ;;chinese
       ;;japanese
       :os
       (tty +osc)

       :completion
       company           ; the ultimate code completion backend
       helm              ; the *other* search engine for love and life
       ;;ido               ; the other *other* search engine...
       ;;ivy               ; a search engine for love and life

       :ui
       deft              ; notational velocity for Emacs
       doom              ; what makes DOOM look the way it does
       doom-dashboard    ; a nifty splash screen for Emacs
       doom-quit         ; DOOM quit-message prompts when you quit Emacs
       ; fill-column       ; a `fill-column' indicator
       hl-todo           ; highlight TODO/FIXME/NOTE/DEPRECATED/HACK/REVIEW
       ;;hydra
       ;;indent-guides     ; highlighted indent columns
       ;minimap           ; show a map of the code on the side
       modeline          ; snazzy, Atom-inspired modeline, plus API
       ;;nav-flash         ; blink cursor line after big motions
       ;;neotree           ; a project drawer, like NERDTree for vim
       ophints           ; highlight the region an operation acts on
       (popup +defaults)   ; tame sudden yet inevitable temporary windows
       ;; pretty-code       ; ligatures or substitute text with pretty symbols
       ;;tabs              ; a tab bar for Emacs
       treemacs          ; a project drawer, like neotree but cooler
       unicode           ; extended unicode support for various languages
       window-select     ; visually switch windows
       vc-gutter         ; vcs diff in the fringe
       vi-tilde-fringe   ; fringe tildes to mark beyond EOB
       workspaces        ; tab emulation, persistence & separate workspaces
       zen               ; distraction-free coding or writing

       :editor
       (evil +everywhere)  ; come to the dark side, we have cookies
       file-templates      ; auto-snippets for empty files
       fold                ; (nigh) universal code folding
       (format +onsave)  ; automated prettiness
       ;;god               ; run Emacs commands without modifier keys
       ;;lispy             ; vim for lisp, for people who don't like vim
       multiple-cursors  ; editing in many places at once
       ;;objed             ; text object editing for the innocent
       ;;parinfer          ; turn lisp into python, sort of
       ;;rotate-text       ; cycle region at point between text candidates
       snippets            ; my elves. They type so I don't have to
       word-wrap           ; soft wrapping with language-aware indent

       :emacs
       dired             ; making dired pretty [functional]
       electric          ; smarter, keyword-based electric-indent
       ibuffer         ; interactive buffer management
       (undo +tree)      ; persistent, smarter undo for your inevitable mistakes
       vc                ; version-control and Emacs, sitting in a tree

       :term
       eshell            ; the elisp shell that works everywhere
       ;;shell             ; simple shell REPL for Emacs
       ;;term              ; basic terminal emulator for Emacs
       ;vterm             ; the best terminal emulation in Emacs

       :checkers
       syntax              ; tasing you for every semicolon you forget
       ;;spell             ; tasing you for misspelling mispelling
       ;;grammar           ; tasing grammar mistake every you make

       :tools
       ;;ansible
       debugger          ; FIXME stepping through code, to help you add bugs
       direnv
       docker
       editorconfig      ; let someone else argue about tabs vs spaces
       ein               ; tame Jupyter notebooks with emacs
       (eval +overlay)     ; run code, run (also, repls)
       ;;gist              ; interacting with github gists
       lookup              ; navigate your code and its documentation
       (lsp +peek)
       macos             ; MacOS-specific commands
       magit             ; a git porcelain for Emacs
       make              ; run make tasks from Emacs
       pass              ; password manager for nerds
       ;; pdf               ; pdf enhancements
       ;;prodigy           ; FIXME managing external services & code builders
       rgb               ; creating color strings
       ;;taskrunner        ; taskrunner for all your projects
       terraform         ; infrastructure as code
       tmux              ; an API for interacting with tmux
       ;;upload            ; map local to remote projects via ssh/ftp

       :lang
       ;;agda              ; types of types of types of types...
       ;;cc                ; C/C++/Obj-C madness
       clojure             ; java with a lisp
       ;;common-lisp       ; if you've seen one lisp, you've seen them all
       ;;coq               ; proofs-as-programs
       ;;crystal           ; ruby at the speed of c
       ;;csharp            ; unity, .NET, and mono shenanigans
       ;;data              ; config/data formats
       ;;(dart +flutter)   ; paint ui and not much else
       ;;elixir            ; erlang done right
       ;;elm               ; care for a cup of TEA?
       emacs-lisp        ; drown in parentheses
       ;;erlang            ; an elegant language for a more civilized age
       ;;ess               ; emacs speaks statistics
       ;;faust             ; dsp, but you get to keep your soul
       ;;fsharp            ; ML stands for Microsoft's Language
       ;;fstar             ; (dependent) types and (monadic) effects and Z3
       ;;gdscript          ; the language you waited for
       (go +lsp)         ; the hipster dialect
       ;;(haskell +dante)  ; a language that's lazier than I am
       ;;hy                ; readability of scheme w/ speed of python
       ;;idris             ;
       json                ; At least it ain't XML
       ;;(java +meghanada) ; the poster child for carpal tunnel syndrome
       javascript          ; all(hope(abandon(ye(who(enter(here))))))
       ;;julia             ; a better, faster MATLAB
       ;;kotlin            ; a better, slicker Java(Script)
       latex               ; writing papers in Emacs has never been so fun
       ;;lean
       ;;factor
       ;;ledger            ; an accounting system in Emacs
       lua               ; one-based indices? one-based indices
       markdown            ; writing docs for people to ignore
       ;;nim               ; python + lisp at the speed of c
       ;;nix               ; I hereby declare "nix geht mehr!"
       ;;ocaml             ; an objective camel
       (org +present +pomodoro +pandoc +hugo);                ; organize your plain life in plain text
       ;;php               ; perl's insecure younger brother
       ;;plantuml          ; diagrams for confusing people more
       ;;purescript        ; javascript, but functional
       python              ; beautiful is better than ugly
       ;;qt                ; the 'cutest' gui framework ever
       racket              ; a DSL for DSLs
       ;;raku              ; the artist formerly known as perl6
       ;;rest              ; Emacs as a REST client
       ;;rst               ; ReST in peace
       (ruby +rails)       ; 1.step {|i| p "Ruby is #{i.even? ? 'love' : 'life'}"}
       ;;rust              ; Fe2O3.unwrap().unwrap().unwrap().unwrap()
       ;;scala             ; java, but good
       ;;scheme            ; a fully conniving family of lisps
       sh                ; she sells {ba,z,fi}sh shells on the C xor
       ;;sml
       ;;solidity          ; do you need a blockchain? No.
       ;;swift             ; who asked for emoji variables?
       ;;terra             ; Earth and Moon in alignment for performance.
       web               ; the tubes
       yaml              ; JSON, but readable

       :email
       ;;(mu4e +gmail)
       ;;notmuch
       ;;(wanderlust +gmail)

       :app
       calendar
       irc               ; how neckbeards socialize
       (rss +org)        ; emacs as an RSS reader
       ;;twitter           ; twitter client https://twitter.com/vnought


       :config
       ;; literate ; don't use literate when manually tangling
       (default +bindings +smartparens))

```

<a id="org6a2581d"></a>

# packages.el

:header-args:emacs-lisp+ :tangle packages.el :header-args:elisp+ :results silent :tangle packages.el

<a id="org13860bd"></a>

## ii-packages

```elisp
(package! ii-utils :recipe
  (:host github
   :branch "master"
   :repo "ii/ii-utils"
   :files ("*.el")))
(package! ii-pair :recipe
  (:host github
   :branch "main"
   :repo "humacs/ii-pair"
   :files ("*.el")))
```

<a id="orga8e224e"></a>

## upstream

```elisp
(package! sql)
(package! ob-sql-mode)
(package! ob-tmux)
(package! ox-gfm) ; org dispatch github flavoured markdown
(package! kubernetes)
(package! kubernetes-evil)
(package! exec-path-from-shell)
(package! tomatinho)
(package! graphviz-dot-mode)
(package! feature-mode)
(package! almost-mono-themes)
(package! graphviz-dot-mode)
```
