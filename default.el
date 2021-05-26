;;; .emacs --- -*- lexical-binding: t; -*-
;;; Commentary:
;; ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;;
;; Humacs - Emacs Profile Switcher v0.1 (based on chemex)
;;
;; INSTALLATION
;;
;; Set your EMACSLOADPATH=$(humacs folder):
;; This file is called default.el and will be loaded
;; The default HUMACS_PROFILE_PATH=~/.emacs-profiles.el, will container default,ii, and doom profiles.
;; Dynamically pointing to sub folders of this project.
;; Install this file as ~/.emacs . Next time you start Emacs it will create a
;;
;;     (("default" . ((user-emacs-directory . "~/.emacs.d"))))
;;
;; Now you can start Emacs with `--with-profile' to pick a specific profile. A
;; more elaborate example:
;;
;;     (("default"                      . ((user-emacs-directory . "~/emacs-profiles/plexus")))
;;      ("spacemacs"                    . ((user-emacs-directory . "~/github/spacemacs")
;;                                         (server-name . "spacemacs")
;;                                         (custom-file . "~/.spacemacs.d/custom.el")
;;                                         (env . (("SPACEMACSDIR" . "~/.spacemacs.d"))))))
;;
;; If you want to change the default profile used (so that, for example, a
;; GUI version of Emacs uses the profile you want), you can also put the name
;; of that profile in a ~/.emacs-profile file

;; ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;; this must be here to keep the package system happy, normally you do
;; `package-initialize' for real in your own init.el
;; (package-initialize)

;;; Code:
(defvar humacs-directory
  (if (getenv "HUMACS_DIRECTORY")
      (getenv "HUMACS_DIRECTORY")
    (file-name-directory load-file-name)))

(defvar humacs-emacs-directory
  (if (getenv "HUMACS_EMACS_DIRECTORY")
      (getenv "HUMACS_EMACS_DIRECTORY")
      (concat humacs-directory "spacemacs")))

(defvar humacs-spacemacs-directory
  (if (getenv "HUMACS_SPACEMACS_DIRECTORY")
      (getenv "HUMACS_SPACEMACS_DIRECTORY")
    (concat humacs-directory "spacemacs-config")))

(defvar humacs-doom-directory
  (if (getenv "HUMACS_DOOM_DIRECTORY")
      (getenv "HUMACS_DOOM_DIRECTORY")
    (concat humacs-directory)))

(defvar humacs-default-profile
  (if (getenv "HUMACS_PROFILE")
      (getenv "HUMACS_PROFILE")
    "default"))

(defvar humacs-profiles-path
  (if (getenv "HUMACS_PROFILES_PATH")
      (getenv "HUMACS_PROFILES_PATH")
      "~/.humacs-profiles.el"))

(defvar humacs-default-profile-path
    (if (getenv "HUMACS_DEFAULT_PROFILE_PATH")
        (getenv "HUMACS_DEFAULT_PROFILE_PATH")
      "~/.humacs-profile"))

(when (not (file-exists-p humacs-profiles-path))
  (with-temp-file humacs-profiles-path
    (insert (concat
             "("
             "\n(\"default\" . ("
             "\n  (user-emacs-directory . \"" humacs-emacs-directory "\")"
             "\n  (env . ("
             "\n    (\"SPACEMACSDIR\" . \"" humacs-spacemacs-directory "\")"
             "\n    (\"DOOMDIR\" . \"" humacs-doom-directory "\")"
             "\n  )"
             ")))"
             "\n(\"ii\" . ("
             "\n  (user-emacs-directory . \"" (concat humacs-directory "spacemacs") "\")"
             "\n  (env . ("
             "\n    (\"SPACEMACSDIR\" . \"" humacs-spacemacs-directory "\")"
             "\n  )"
             ")))"
             "\n(\"doom\" . ("
             "\n  (user-emacs-directory . \"" (concat humacs-directory "doom-emacs") "\")"
             "\n  (env . ("
             "\n    (\"DOOMDIR\" . \"" humacs-doom-directory "\")"
             "\n  )"
             ")))"
             "\n)"
             )
            )))

(defvar humacs-emacs-profiles
  (with-temp-buffer
    (insert-file-contents humacs-profiles-path)
    (goto-char (point-min))
    (read (current-buffer))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun humacs-detect-default-profile ()
  (if (file-exists-p humacs-default-profile-path)
      (with-temp-buffer
        (insert-file-contents humacs-default-profile-path)
        (goto-char (point-min))
        ;; (buffer-string))
        (setq foo (symbol-name (read (current-buffer)) ))
        (message "HUMACS-DEFAULTED-PROFILE")
        (message foo)
        (symbol-value 'foo)
        )
    (progn
      (message "HUMACS-ENVDRIVEN-PROFILE")
      (message humacs-default-profile)
      (symbol-value 'humacs-default-profile)
      )
    )
  )

(defun humacs-load-straight ()
  (defvar bootstrap-version)
  (let ((bootstrap-file (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
        (bootstrap-version 5))
    (unless (file-exists-p bootstrap-file)
      (with-current-buffer
          (url-retrieve-synchronously
           "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
           'silent 'inhibit-cookies)
        (goto-char (point-max))
        (eval-print-last-sexp)))
    (load bootstrap-file nil 'nomessage)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun humacs-get-emacs-profile (profile)
  (cdr (assoc profile humacs-emacs-profiles)))

(defun humacs-emacs-profile-key (key &optional default)
  (alist-get key (humacs-get-emacs-profile humacs-current-emacs-profile)
             default))

(defun humacs-load-profile (profile)
  (when (not (humacs-get-emacs-profile profile))
    (error "No profile `%s' in %s" profile humacs-profiles-path))
  (setq humacs-current-emacs-profile profile)
  (let* ((emacs-directory (file-name-as-directory
                           (humacs-emacs-profile-key 'user-emacs-directory)))
         (init-file       (expand-file-name "init.el" emacs-directory))
         (custom-file-    (humacs-emacs-profile-key 'custom-file init-file))
         (server-name-    (humacs-emacs-profile-key 'server-name)))
    (setq user-emacs-directory emacs-directory)

    ;; Allow multiple profiles to each run their server
    ;; use `emacsclient -s profile_name' to connect
    (when server-name-
      (setq server-name server-name-))

    ;; Set environment variables, these are visible to init-file with getenv
    (mapcar (lambda (env)
              (setenv (car env) (cdr env)))
            (humacs-emacs-profile-key 'env))

    (when (humacs-emacs-profile-key 'straight-p)
      (humacs-load-straight))

    ;; Start the actual initialization
    (load init-file)

    ;; Prevent customize from changing ~/.emacs (this file), but if init.el has
    ;; set a value for custom-file then don't touch it.
    (when (not custom-file)
      (setq custom-file custom-file-)
      (unless (equal custom-file init-file)
        (load custom-file)))))

(defun humacs-check-command-line-args (args)
  (if args
      ;; Handle either `--with-profile profilename' or
      ;; `--with-profile=profilename'
      (let ((s (split-string (car args) "=")))
        (cond ((equal (car args) "--with-profile")
               ;; This is just a no-op so Emacs knows --with-profile
               ;; is a valid option. If we wait for
               ;; command-switch-alist to be processed then
               ;; after-init-hook has already run.
               (add-to-list 'command-switch-alist
                            '("--with-profile" .
                              (lambda (_) (pop command-line-args-left))))
               ;; Load the profile
               (humacs-load-profile (cadr args)))

              ;; Similar handling for `--with-profile=profilename'
              ((equal (car s) "--with-profile")
               (add-to-list 'command-switch-alist `(,(car args) . (lambda (_))))
               (humacs-load-profile (mapconcat 'identity (cdr s) "=")))

              (t (humacs-check-command-line-args (cdr args)))))

    ;; If no profile given, load the "default" profile
    (humacs-load-profile (humacs-detect-default-profile))))

;; Check for a --with-profile flag and honor it; otherwise load the
;; default profile.
(humacs-check-command-line-args command-line-args)

(provide '.emacs)
;;; .emacs ends here
