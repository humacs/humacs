(setq user-full-name (if (getenv "GIT_AUTHOR_NAME")
                         (getenv "GIT_AUTHOR_NAME")
                       "ii friend")
      user-mail-address (if (getenv "GIT_COMMIT_EMAIL")
                            (getenv "GIT_COMMIT_EMAIL")
                          "ii*ii.ii"))

(setq doom-localleader-key ",")

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

(map!
 :map smartparens-mode-map
 :nv ">" #'sp-forward-slurp-sexp
 :nv "<" #'sp-forward-barf-sexp
 :nv "}" #'sp-backward-barf-sexp
 :nv "{" #'sp-backward-slurp-sexp)

(when (memq window-system '(mac ns x)) (exec-path-from-shell-initialize))

;(setq doom-font (font-spec :family "Source Code Pro" :size 10)
;      ;; )(font-spec :family "Source Code Pro" :size 8 :weight 'semi-light)
;      doom-serif-font (font-spec :family "Source Code Pro" :size 10)
;      doom-variable-pitch-font (font-spec :family "Source Code Pro" :size 10)
;      doom-unicode-font (font-spec :family "Input Mono Narrow" :size 12)
;      doom-big-font (font-spec :family "Source Code Pro" :size 10))

(setq doom-theme 'doom-gruvbox)

(setq standard-indent 2)

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

(setq web-mode-enable-auto-closing t)
(setq-hook! web-mode web-mode-auto-close-style 2)

(when (and (getenv "HUMACS_PROFILE") (not (getenv "GOPATH")))
  (setenv "GOPATH" (concat (getenv "HOME") "/go")))

(define-derived-mode ii-vue-mode web-mode "iiVue"
  "A major mode derived from web-mode, for editing .vue files with LSP support.")
(add-to-list 'auto-mode-alist '("\\.vue\\'" . ii-vue-mode))
(add-hook 'ii-vue-mode-hook #'lsp!)

(setq org-cycle-hook
      ' (org-cycle-hide-archived-subtrees
         org-cycle-show-empty-lines
         org-optimize-window-after-visibility-change))

(defun ek/babel-ansi ()
  (when-let ((beg (org-babel-where-is-src-block-result nil nil)))
    (save-excursion
      (goto-char beg)
      (when (looking-at org-babel-result-regexp)
        (let ((end (org-babel-result-end))
              (ansi-color-context-region nil))
          (ansi-color-apply-on-region beg end))))))
(add-hook 'org-babel-after-execute-hook 'ek/babel-ansi)

(setq org-babel-default-header-args:sql-mode
      '((:results . "replace code")
        (:product . "postgres")
        (:wrap . "SRC example")))

(setq org-babel-default-header-args:go
      '((:results . "replace code")
        (:wrap . "SRC example")))

(use-package! graphviz-dot-mode)
(use-package! sql)
(use-package! ii-utils)
(use-package! ii-pair)
(after! ii-pair
  (osc52-set-cut-function)
  )
;;(use-package! iterm)
;;(use-package! ob-tmate)

(require 'ox-gfm)

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

(setq
      ;; user-banners-dir
      ;; doom-dashboard-banner-file "img/kubemacs.png"
      doom-dashboard-banner-dir (concat humacs-spacemacs-directory  (convert-standard-filename "/banners/"))
      doom-dashboard-banner-file "img/kubemacs.png"
      fancy-splash-image (concat doom-dashboard-banner-dir doom-dashboard-banner-file)
      )

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
