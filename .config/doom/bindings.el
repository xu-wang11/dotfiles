;;; -*- lexical-binding: t; no-byte-compile: t -*-

(after! evil-mc
  (global-evil-mc-mode 0)
  (add-hook 'evil-mc-after-cursors-deleted #'turn-off-evil-mc-mode))

;; expand-region's prompt can't tell what key contract-region is bound to, so we tell it explicitly.
(setq expand-region-contract-fast-key "H")

(map!
 ;; Ensure there are no conflicts
 :nmvo doom-leader-key nil
 :nmvo doom-localleader-key nil

 ;; swap ret/c-j
 :gi "RET" #'newline-and-indent
 :i "C-j" #'+default/newline
 ;;(:after debug :map debugger-mode-map
 ;;  :nmvo doom-leader-key nil)
 (:after dired :map dired-mode-map
   :nmv ";" nil
   :nmv "]" nil
   :nmv "[" nil)

 ;; --- Global keybindings ---------------------------
 ;; clean-ups:
 :gnvime "M-l" nil
 :gnvime "M-h" nil


 ;; Make M-x available everywhere
 :gnvime "M-x" #'execute-extended-command
 :gnvime "C-x C-b" #'ibuffer

 :n "M-r"   #'+eval/buffer
 :n "M-f"   #'swiper
 ;;:n  "M-s"   #'save-buffer

 :nm  ";"     #'evil-ex
 :nm  "*"     #'highlight-symbol-at-point

 :nv [tab]   #'+evil/matchit-or-toggle-fold
 ;; delete to blackhole register
 :v  [delete] (lambda! ()
                       (let ((evil-this-register ?_))
                         (call-interactively #'evil-delete)))

 (:when IS-LINUX
   :nvm "C-z" #'zeal-at-point)
 :nv "K"  #'+lookup/documentation
 :nm "gd" #'+lookup/definition
 :nm "gD" #'+lookup/references
 :nm "gw" #'avy-goto-word-1
 :n  "gx"  #'evil-exchange  ; https://github.com/tommcdo/vim-exchange

 :nv "C-a"   #'evil-numbers/inc-at-pt
 :nv "C-S-a" #'evil-numbers/dec-at-pt

 ;; Vim-like editing commands
 :i "C-j"   #'evil-next-line
 :i "C-k"   #'evil-previous-line
 :i "C-h"   #'evil-backward-char
 :i "C-l"   #'evil-forward-char

 :i "C-S-V" #'yank
 :i "C-a"   #'doom/backward-to-bol-or-indent
 :i "C-e"   #'doom/forward-to-last-non-comment-or-eol
 :i "C-u"   #'doom/backward-kill-to-bol-and-indent
 :i "C-b"   #'backward-word
 :i "C-f"   #'forward-word
 (:map (minibuffer-local-map
        minibuffer-local-ns-map
        minibuffer-local-completion-map
        minibuffer-local-must-match-map
        minibuffer-local-isearch-map
        read-expression-map)
   [escape] #'abort-recursive-edit
   "C-a"    #'move-beginning-of-line
   "C-w"    #'backward-kill-word
   "C-u"    #'backward-kill-sentence
   "C-b"    #'backward-word
   "C-f"    #'forward-word
   "C-S-V"  #'yank
   )
 (:after evil :map evil-ex-completion-map
   "C-a"   #'move-beginning-of-line
   "C-b"   #'backward-word
   "C-f"   #'forward-word
   "C-S-V" #'yank
   )

 ;; expand-region
 :v  "L"  #'er/expand-region
 :v  "H"  #'er/contract-region

 ;; workspace/tab related
 :nm "M-t"       #'+workspace/new
 :nm "M-T"       #'+workspace/display
 :nmi "M-1"       (λ! (+workspace/switch-to 0))
 :nmi "M-2"       (λ! (+workspace/switch-to 1))
 :nmi "M-3"       (λ! (+workspace/switch-to 2))
 :nmi "M-4"       (λ! (+workspace/switch-to 3))
 :nmi "M-5"       (λ! (+workspace/switch-to 4))
 :nmi "M-6"       (λ! (+workspace/switch-to 5))
 :nmi "M-7"       (λ! (+workspace/switch-to 6))
 :nmi "M-8"       (λ! (+workspace/switch-to 7))
 :nmi "M-9"       (λ! (+workspace/switch-to 8))
 :nmi "M-0"       #'+workspace/switch-to-last
 ;; window management
 :nm "C-h"   #'evil-window-left
 :nm "C-j"   #'evil-window-down
 :nm "C-k"   #'evil-window-up
 :nm "C-l"   #'evil-window-right

 :nm  "]b" #'next-buffer
 :nm  "[b" #'previous-buffer
 ;; TODO if under GUI, use alt-hl
 :nm  "]w" #'+workspace/switch-right
 :nm  "[w" #'+workspace/switch-left
 :nm  "]e" #'next-error
 :nm  "[e" #'previous-error
 :nm  "]d" #'git-gutter:next-hunk
 :nm  "[d" #'git-gutter:previous-hunk

 :nme "C--" #'text-scale-decrease
 :nme "C-=" #'text-scale-increase

 ;; company-mode
 "C-SPC" nil  ;; clear
 :i "C-SPC"  #'+company/complete
 (:prefix "C-x"
   :i "C-l"   #'+company/whole-lines
   :i "C-k"   #'+company/dict-or-keywords
   :i "C-f"   #'company-files
   ;;:i "C-]"   #'company-etags
   ;;:i "C-s"   #'company-yasnippet
   :i "C-s"   #'yas-expand
   :i "C-o"   #'+company/complete
   ;;:i "C-o"   #'company-capf
   :i "C-n"   #'+company/dabbrev
   :i "C-p"   #'+company/dabbrev-code-previous)

 (:after company
   (:map company-active-map
     ;; Don't interfere with `evil-delete-backward-word' in insert mode
     "C-w"     nil
     "C-n"     #'company-select-next
     "C-p"     #'company-select-previous
     "C-h"     #'company-show-doc-buffer
     "C-s"     #'company-filter-candidates
     [tab]     #'company-complete-common-or-cycle
     [tab]     #'company-complete-common-or-cycle
     "S-TAB"   #'company-select-previous
     [backtab] #'company-select-previous
     "<f1>"    nil
     [escape]  (lambda! (company-abort) (evil-normal-state))
     )
   (:map company-search-map
     "C-n"     #'company-select-next-or-abort
     "C-p"     #'company-select-previous-or-abort
     "C-s"     (λ! (company-search-abort) (company-filter-candidates))
     [escape]  #'company-search-abort)
   )

 ;; just like vim ctrlp
 :nm "C-p" #'counsel-projectile-find-file
 (:after counsel :map counsel-ag-map
   [backtab]  #'+ivy/wgrep-occur      ; search/replace on results
   "C-SPC"    #'ivy-call-and-recenter ; preview
   )

 (:after evil
   :textobj "a" #'evil-inner-arg                    #'evil-outer-arg
   :textobj "i" #'evil-indent-plus-i-indent         #'evil-indent-plus-a-indent
   (:map evil-window-map ; prefix "C-w"
     ;; Navigation
     "C-h"     #'evil-window-left
     "C-j"     #'evil-window-down
     "C-k"     #'evil-window-up
     "C-l"     #'evil-window-right
     "C-w"     #'other-window
     ;; Swapping windows
     "H"       #'+evil/window-move-left
     "J"       #'+evil/window-move-down
     "K"       #'+evil/window-move-up
     "L"       #'+evil/window-move-right
     ;; Window undo/redo
     "u"       #'winner-undo
     "C-r"     #'winner-redo
     "o"       #'doom/window-enlargen
     ;; Delete window
     "c"       #'+workspace/close-window-or-workspace
     "C-C"     #'ace-delete-window
     [up]      #'evil-window-increase-height
     [down]    #'evil-window-decrease-height
     [right]   #'evil-window-increase-width
     [left]    #'evil-window-decrease-width
     )
   )

 ;; doom already clears the map, which is nice!
 (:after evil-mc :map evil-mc-key-map
   :nv "C-n" #'evil-mc-make-and-goto-next-match
   :nv "C-p" #'evil-mc-make-and-goto-prev-match
   :nv "C-S-n" #'evil-mc-skip-and-goto-next-match
   :nv "C-S-p" #'evil-mc-skip-and-goto-prev-match)

 ;; surround
 (:after evil-surround
   :map evil-surround-mode-map
   :v "s" 'evil-surround-region
   )   ; originally was snipe
 :o  "s"  #'evil-surround-edit

 ;; flycheck
 (:after flycheck
   :map flycheck-error-list-mode-map
   :n "C-j" #'evil-window-down
   :n "C-k" #'evil-window-up
   :n "j"   #'flycheck-error-list-next-error
   :n "k"   #'flycheck-error-list-previous-error
   :n "RET" #'flycheck-error-list-goto-error)

 ;; git-timemachine
 (:after git-timemachine
   (:map git-timemachine-mode-map
     :n "C-p" #'git-timemachine-show-previous-revision
     :n "C-n" #'git-timemachine-show-next-revision
     :n "[["  #'git-timemachine-show-previous-revision
     :n "]]"  #'git-timemachine-show-next-revision
     :n "q"   #'git-timemachine-quit
     :n "gb"  #'git-timemachine-blame))

 ;; ivy
 (:after ivy
   (:map ivy-minibuffer-map
     [escape] #'keyboard-escape-quit
     "C-SPC"  #'ivy-call-and-recenter  ; preview

     ;; basic editing
     "C-S-V"  #'yank
     "C-w"    #'ivy-backward-kill-word
     "C-u"    #'ivy-kill-whole-line
     "C-b"    #'backward-word
     "C-f"    #'forward-word

     ;; movement
     "C-k"    #'ivy-previous-line
     "C-j"    #'ivy-next-line
     ;; split window and execute action, similar to ctrlp.vim
     "C-v"    (lambda! (my/ivy-exit-new-window 'right))
     "C-s"    (lambda! (my/ivy-exit-new-window 'below))
     )
   (:map ivy-switch-buffer-map
     "C-d" 'ivy-switch-buffer-kill
     ))

 (:after swiper
   (:map swiper-map
     [backtab]  #'+ivy/wgrep-occur))

 ;; neotree
 (:after neotree
   :map neotree-mode-map
   :n "g"         nil
   :n [tab]       #'neotree-quick-look
   :n "RET"       #'neotree-enter
   :n [backspace] #'evil-window-prev
   :n "q"         #'neotree-hide
   :n "R"         #'neotree-refresh

   :n "c"         #'neotree-create-node
   :n "r"         #'neotree-rename-node
   :n "d"         #'neotree-delete-node

   :n "j"         #'neotree-next-line
   :n "k"         #'neotree-previous-line
   :n "h"         #'+neotree/collapse-or-up
   :n "l"         #'+neotree/expand-or-open
   :n "J"         #'neotree-select-next-sibling-node
   :n "K"         #'neotree-select-previous-sibling-node
   :n "H"         #'neotree-select-up-node
   :n "L"         #'neotree-select-down-node

   :n "G"         #'evil-goto-line
   :n "gg"        #'evil-goto-first-line
   :n "C-v"       #'neotree-enter-vertical-split
   :n "C-s"       #'neotree-enter-horizontal-split
   )

 (:after yasnippet
   (:map yas-keymap
     "C-e"           #'+snippets/goto-end-of-field
     "C-u"           #'+snippets/delete-to-start-of-field
     "C-a"           #'+snippets/goto-start-of-field
     [backspace]     #'+snippets/delete-backward-char
     [delete]        #'+snippets/delete-forward-char-or-field
     )
   (:map yas-minor-mode-map
     "SPC"           yas-maybe-expand
     ))

 (:when (featurep! :completion company)
   (:after comint
   ;; TAB auto-completion in term buffers
   :map comint-mode-map [tab] #'company-complete))

 (:map* (help-mode-map helpful-mode-map)
   :n "o"  #'ace-link-help
   :n "q"  #'quit-window
   :n "Q"  #'ivy-resume)

 (:after goto-addr
   :map goto-address-highlight-keymap
   "RET" #'goto-address-at-point)
 (:after view :map view-mode-map
   "<escape>" #'View-quit-all)
 )


(map! :leader
      ;; :desc "M-x"                     :nv ":"  #'execute-extended-command
                                        ; jumps:
      :desc "Find file in project"       :n "SPC" #'projectile-find-file
      :desc "Switch workspace buffer"    :n ","   #'persp-switch-to-buffer
      :desc "Switch buffer"              :n "<"   #'switch-to-buffer
      :desc "Find files from here"       :n "."   #'counsel-file-jump
      :desc "Toggle last popup"          :n "~"   #'+popup/toggle
      (:when (featurep! :completion ivy)
        :desc "Resume last search"     :n "'"   #'ivy-resume)
                                        ; :desc "Blink cursor line"          :n "DEL" #'+nav-flash/blink-cursor
      :desc "Create or jump to bookmark" :n "RET" #'bookmark-jump

      :desc "Universal argument"         :n "u"  #'universal-argument
      :desc "window"                     :n "w"  evil-window-map


      (:desc "previous..." :prefix "["
        :desc "Buffer"                :nv "b" #'previous-buffer
        :desc "Diff Hunk"             :nv "d" #'git-gutter:previous-hunk
        :desc "Error"                 :nv "e" #'previous-error
        :desc "Spelling error"        :nv "s" #'evil-prev-flyspell-error
        )
      (:desc "next..." :prefix "]"
        :desc "Buffer"                :nv "b" #'next-buffer
        :desc "Diff Hunk"             :nv "d" #'git-gutter:next-hunk
        :desc "Error"                 :nv "e" #'next-error
        :desc "Spelling error"        :nv "s" #'evil-next-flyspell-error
        )

      (:desc "search" :prefix "/"
        :desc "Project"                :nv "/" #'+ivy/project-search
        :desc "Project"                :nv "p" #'+ivy/project-search
        :desc "This Directory"         :nv "d" #'+ivy/project-search-from-cwd
        :desc "In Buffer (swiper)"     :nv "b" #'swiper
        :desc "Tags (imenu)"           :nv "t" #'imenu
        :desc "Tags across buffers"    :nv "T" #'imenu-anywhere
        :desc "Online providers"       :nv "o" #'+lookup/online-select)

      (:desc "workspace" :prefix [tab]
        :desc "Display tab bar"          :n [tab] #'+workspace/display
        :desc "New workspace"            :n "n"   #'+workspace/new
        :desc "Load last session"        :n "L"   #'+workspace/load-session
        :desc "Autosave current session" :n "S"   #'+workspace/save-session
        :desc "Switch workspace"         :n "."   #'+workspace/switch-to
        :desc "Kill all buffers"         :n "x"   #'doom/kill-all-buffers
                                        ;:desc "Delete session"           :n "X"   #'+workspace/kill-session
        :desc "Delete this workspace"    :n "d"   #'+workspace/delete
                                        ;:desc "Load session"             :n "L"   #'+workspace/load-session
        :desc "Rename workspace"         :n "r"   #'+workspace/rename
        :desc "Next workspace"           :n "]"   #'+workspace/switch-right
        :desc "Previous workspace"       :n "["   #'+workspace/switch-left)

      (:desc "buffer" :prefix "b"
        :desc "Kill buffer"             :n "k" #'kill-this-buffer
        :desc "Kill other buffers"      :n "o" #'doom/kill-other-buffers
        :desc "Switch workspace buffer" :n "b" #'switch-to-buffer
        :desc "Next buffer"             :n "]" #'next-buffer
        :desc "Previous buffer"         :n "[" #'previous-buffer
        :desc "Sudo edit this file"     :n "S" #'doom/sudo-this-file)

      (:desc "code" :prefix "c"
                                        ; TODO https://github.com/redguardtoo/evil-nerd-commenter
        :desc "Commentary"              :v "c" #'evil-commentary
        :n "c" #'evil-commentary-line
        :desc "List errors"             :n "x" #'flycheck-list-errors
        :desc "Evaluate buffer/region"  :n "e" #'+eval/buffer
        :v "e" #'+eval/region
        :desc "Diff with File"          :n "d" #'diff-buffer-with-file
        :desc "Rotate text"             :n "!" #'rotate-text  ;https://www.emacswiki.org/emacs/RotateText
        :desc "Insert snippet"         :nv "s" #'yas-insert-snippet
        :desc "Start MultiCursor"       :n "m" #'turn-on-evil-mc-mode
        :v "m" (lambda! () (turn-on-evil-mc-mode) (evil-mc-make-all-cursors))
        )

      (:desc "file" :prefix "f"
        :desc "File Manager"              :n "m" #'+neotree/find-this-file
        :desc "Find file from here"       :n "." #'counsel-file-jump
        :desc "Sudo find file"            :n ">" #'doom/sudo-find-file
        :desc "Find file in project"      :n "p" #'projectile-find-file
        :desc "Find file"                 :n "f" #'find-file
        :desc "Find directory"            :n "d" #'dired
        :desc "Switch buffer"             :n "b" #'switch-to-buffer

        :desc "Recent files"              :n "r" #'recentf-open-files
        :desc "Recent project files"      :n "R" #'projectile-recentf
        :desc "Copy current filename"     :n "y" #'+default/yank-buffer-filename
        :desc "Find emacs library"        :n "l" #'find-library

        :desc "Find file in emacs.d"      :n "e" #'+default/find-in-emacsd
        :desc "Browse emacs.d"            :n "E" #'+default/browse-emacsd
        :desc "Find file in dotfiles"     :n "D" #'+default/find-in-config)

      (:desc "git" :prefix "g"
        :desc "Magit blame"            :n  "b" #'magit-blame
        :desc "Magit diff this file"   :n  "d" #'magit-diff-buffer-file
        :desc "Magit diff repo"        :n  "D" #'magit-diff-working-tree
        :desc "Magit status"           :n  "g" #'magit-status
        :desc "Magit repo log"         :n  "l" #'magit-log-current
        :desc "Magit log for this file":n  "L" #'magit-log-buffer-file
        :desc "Magit push popup"       :n  "p" #'magit-push-popup
        :desc "Magit pull popup"       :n  "P" #'magit-pull-popup
        :desc "Git revert hunk"        :n  "r" #'git-gutter:revert-hunk
        :desc "Git revert file"        :n  "R" #'vc-revert
        :desc "Git stage hunk"         :n  "s" #'git-gutter:stage-hunk
                                        ;:desc "Git stage file"        :n  "S" #'magit-stage-file
        :desc "Git time machine"       :n  "t" #'git-timemachine-toggle
        :desc "Copy URL of line"       :n  "C" #'git-link
        :desc "Browse Issues"          :n  "I" #'+vcs/git-browse-issues
                                        ;:desc "Git unstage file"      :n  "U" #'magit-unstage-file
        :desc "Next hunk"              :nv "]" #'git-gutter:next-hunk
        :desc "Previous hunk"          :nv "[" #'git-gutter:previous-hunk)

      (:desc "help" :prefix "h"
        :n "h" help-map
        :desc "Apropos"               :n  "a" #'apropos
        :desc "Describe bindings"     :n  "b" #'describe-bindings
        :desc "Describe char"         :n  "c" #'describe-char
        :desc "Describe DOOM module"  :n  "D" #'doom/describe-module
        :desc "Describe function"     :n  "f" #'describe-function
        :desc "Describe face"         :n  "F" #'describe-face
        :desc "Info"                  :n  "i" #'info-lookup-symbol
        :desc "Describe key"          :n  "k" #'describe-key
        :desc "Find documentation"    :n  "K" #'+lookup/documentation
        :desc "Command log"           :n  "L" #'global-command-log-mode
        :desc "Describe mode"         :n  "m" #'describe-mode
        :desc "Toggle Emacs log"      :n  "M" #'view-echo-area-messages
        :desc "Describe variable"     :n  "v" #'describe-variable
        :desc "Where is"              :n  "w" #'where-is
        :desc "Describe at point"     :n  "." #'helpful-at-point
        :desc "What face"             :n  "'" #'doom/what-face)

      (:desc "project" :prefix "p"
        :desc "Browse project"          :n  "." #'+default/browse-project
        :desc "Run cmd in project root" :nv "!" #'projectile-run-shell-command-in-root
        :desc "Compile project"         :n  "c" #'projectile-compile-project
        :desc "Switch project"          :n  "p" #'projectile-switch-project
        :desc "Recent project files"    :n  "r" #'projectile-recentf
        :desc "List project tasks"      :n  "t" #'+ivy/tasks
        :desc "Invalidate cache"        :n  "x" #'projectile-invalidate-cache)

      ;; Unorganized:
      (:desc "run Stuff" :prefix "r"
        :desc "Eval Buffer" :n "r" #'+eval/buffer
        :desc "Terminal"    :n "t" #'multi-term
        :desc "Make"        :n "m" #'+make/run
        )

      (:desc "toggle" :prefix "t"
        :desc "Spell"                  :n "S" #'flyspell-mode
        :desc "Syntax (flycheck)"      :n "s" #'flycheck-mode
        :desc "Taglist (imenu-list)"  :nv "l" #'imenu-list-smart-toggle
        :desc "Line Numbers"           :n "L" #'doom/toggle-line-numbers
        :desc "Neotree"                :n "f" #'+neotree/open
        :desc "Frame Fullscreen"       :n "F" #'toggle-frame-fullscreen
        :desc "Indent Guides"          :n "i" #'highlight-indent-guides-mode
        :desc "Line Wrap"              :n "w" #'visual-line-mode
        :desc "Command Log"            :n "C" #'clm/toggle-command-log-buffer
        )

      (:desc "XXX" :prefix "n"
        :desc "No Highlight" :n "o" (lambda! ()
                                             (evil-ex-nohighlight)
                                             (unhighlight-regexp t)
                                             (evil-mc-undo-all-cursors))
        )

      (:after json-mode :map json-mode-map
        :n "js" #'json-mode-beautify
        :n "bu" #'json-mode-beautify
        )
      (:after javascript-mode :map javascript-mode-map
        :n "js" #'web-beautify-js
        :n "bu" #'web-beautify-js
        )
      (:after web-mode :map web-mode-map
        :n "bu" #'web-beautify-html)
      (:after css-mode :map css-mode-map
        :n "bu"  #'web-beautify-css
        :n "css" #'web-beautify-css
        )
      ) ;; end of leader

(after! man
  (evil-define-key* 'normal Man-mode-map "q" #'kill-this-buffer))

;; (defun +config|save-my-favorite-keys (_feature keymaps)
;;   "Unmap keys that conflict with Doom's defaults."
;;   (dolist (map keymaps)
;;     (evil-delay `(and (boundp ',map) (keymapp ,map))
;;         `(evil-define-key* '(normal visual motion) ,map
;;                            ";" nil
;;                            (kbd doom-leader-key) nil
;;                            (kbd "C-j") nil (kbd "C-k") nil
;;                            "gd" nil "gf" nil "K"  nil "gD" nil "gw" nil
;;                            "]"  nil "["  nil)
;;       'after-load-functions t nil
;;       (format "doom-define-key-in-%s" map))))

;; (add-hook 'evil-collection-setup-hook #'+config|save-my-favorite-keys)

(setq evil-collection-key-blacklist
      (list "C-j" "C-k"
            "gd" "gf" "K"
            "[" "]"
            ";" doom-leader-key))
