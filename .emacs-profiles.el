(
 ("spacemacs" . ((user-emacs-directory . "~/humacs/spacemacs")
                 (spacemacs-banner-advice .
                                       (advice-add
                                        'spacemacs-buffer//choose-banner
                                        :before
                                        (lambda ()
                                          (defconst spacemacs-banner-directory
                                            "~/humacs/spacemacs-config/banners" ))))
                 (env . (("SPACEMACSDIR" . "~/humacs/spacemacs-config")))))
 ("wil" . ((user-emacs-directory . "~/humacs/spacemacs")
                 (env . (("SPACEMACSDIR" . "~/humacs/wil")))))
 ("doom" . ((user-emacs-directory . "~/humacs/doom-emacs")
           (env . (("DOOMDIR" . "~/humacs/doom-config")))))
 ("sachac" . ((user-emacs-directory . "~/humacs/sachac")))
 ("prelude" . ((user-emacs-directory . "~/humacs/prelude")))
)
