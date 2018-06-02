;;; -*- lexical-binding: t; no-byte-compile: t -*-

(after! quickrun
  (setq quickrun-timeout-seconds 30)
  (quickrun-add-command "c++/c1z"
    '((:command . "g++")
      (:exec    . ("%c -std=c++1z %o -o %e -Wall -Wextra %s"
                   "%e %a"))
      (:remove  . ("%e")))
    :default "c++"))

(def-package! lsp-mode :defer t)

(def-package! lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :config
  (setq
   lsp-ui-sideline-enable nil  ; too much noise
   lsp-ui-doc-include-signature t
   lsp-ui-peek-expand-function (lambda (xs) (mapcar #'car xs)))
  (when (featurep! :ui doom)
    (setq
     lsp-ui-doc-background (doom-color 'base4)
     lsp-ui-doc-border (doom-color 'fg))))

(def-package! ccls
  :hook (c-mode-common . lsp-ccls-enable)
  :when (executable-find "ccls")
  :config
  (setq ccls-executable (executable-find "ccls"))
  (setq ccls-sem-highlight-method nil)
  (setq ccls-extra-args '("--log-file=/tmp/ccls.log"))
  (setq ccls-extra-init-params
        '(:completion (:detailedLabel t)
                      :diagnostics (:frequencyMs 5000)))

  (with-eval-after-load 'projectile
    (add-to-list 'projectile-globally-ignored-directories ".ccls-cache"))

  (evil-set-initial-state 'ccls-tree-mode 'emacs)
  (set! :company-backend '(c-mode c++-mode) '(company-lsp)))

(after! python
  (defun spacemacs/python-annotate-debug ()
    "Highlight debug lines. Copied from spacemacs."
    (interactive)
    (highlight-lines-matching-regexp "import \\(pdb\\|ipdb\\|pudb\\|wdb\\)")
    (highlight-lines-matching-regexp "\\(pdb\\|ipdb\\|pudb\\|wdb\\).set_trace()")
    (highlight-lines-matching-regexp "import IPython")
    (highlight-lines-matching-regexp "import sys; sys.exit"))
  (add-hook 'python-mode-hook #'spacemacs/python-annotate-debug)
  (add-hook 'python-mode-hook #'highlight-indent-guides-mode)
  (when (executable-find "ipython")
    ;; my fancy ipython prompt
    (setq python-shell-prompt-regexp "╭─.*\n.*╰─\\$ "
          python-shell-prompt-block-regexp "\\.\\.\\.: ")
    )
  )

(defun my/apply-conf-after-save()
  (let* ((filename (buffer-file-name))
         (basename (file-name-nondirectory filename)))
    (pcase basename
      (".tmux.conf" (call-process "tmux" nil nil nil "source" filename))
      (".Xresources" (call-process "xrdb" nil nil nil filename))
      (".xbindkeysrc" (call-process-shell-command "killall -HUP xbindkeys"))
      )))
(add-hook 'after-save-hook #'my/apply-conf-after-save)
(add-to-list 'auto-mode-alist '(".xbindkeysrc" . conf-mode))

(defun display-ansi-colors ()
  (interactive)
  (require 'tty-format)
  (format-decode-buffer 'ansi-colors))
(add-to-list 'auto-mode-alist '("\\.log\\'" . display-ansi-colors))
