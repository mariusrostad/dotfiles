;; -*- lexical-binding: t; -*-

;;; --- Custom configuration --------------------------------------------

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")

;; --- Turns on mouse and mouse-scroll
(unless (display-graphic-p)
  (xterm-mouse-mode 1)
  (mouse-wheel-mode 1))

;; --- Not sure what it does, but it was recommended for mac users in the nordics
;;(setq mac-option-key-is-meta nil)
;;(setq mac-command-key-is-meta t)
;;(setq mac-command-modifier 'meta)
;;(setq mac-option-modifier nil)

;; --- Hopefully fixes my issues with Mac + Norwegian meta keys
(when (eq system-type 'darwin)
  (setq mac-option-modifier 'meta          ; left Option = Meta
        mac-right-option-modifier 'none    ; right Option = normal macOS (for @ $ { } [ ] | \)
        mac-command-modifier 'super))      ; Cmd = Super (keeps Cmd-c/Cmd-v style bindings free)

(fido-vertical-mode 1)   ; vertical candidate list with flex (fuzzy) matching

;;; --- Package setup ---------------------------------------------------

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Refresh the package list the first time, if it's empty
(unless package-archive-contents
  (package-refresh-contents))

;; use-package is built into Emacs 29+. On Emacs 28 or older, install it:
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)

(use-package doom-themes
  :ensure t
  :custom
  ;; Global settings (defaults)
  (doom-themes-enable-bold t)   ; if nil, bold is universally disabled
  (doom-themes-enable-italic t) ; if nil, italics is universally disabled
  ;; for treemacs users
  (doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  :config
  (load-theme 'doom-1337 t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (nerd-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

;;; --- Rust ------------------------------------------------------------

;; GUI Emacs started from the Dock doesn't get the shell's PATH,
;; so tell it where cargo, rustfmt and rust-analyzer (all via rustup) live.
(when (eq system-type 'darwin)
  (let ((dir (expand-file-name "~/.cargo/bin")))
    (add-to-list 'exec-path dir)
    (setenv "PATH" (concat dir path-separator (getenv "PATH")))))

(use-package rust-mode
  :ensure t
  :init
  (setq rust-mode-treesitter-derive t) ; build on rust-ts-mode; must be set before rust-mode loads
  :custom
  (rust-format-on-save t)        ; run rustfmt when saving
  ;; rustfmt is fed the buffer via stdin, so it can't see Cargo.toml's
  ;; edition and falls back to 2015 (which rejects `async fn' etc.).
  (rust-rustfmt-switches '("--edition" "2024"))
  :hook
  (rust-mode . eglot-ensure))    ; start rust-analyzer via built-in Eglot

(use-package eglot
  :custom
  (eglot-autoshutdown t)         ; stop rust-analyzer when the last buffer closes
  :config
  ;; Run clippy instead of `cargo check' (from the rust-analyzer manual)

  (add-to-list 'eglot-server-programs
               '((rust-ts-mode rust-mode) .
                 ("rust-analyzer" :initializationOptions (:check (:command "clippy"))))))

;; Completion popup for the candidates Eglot provides
(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)
  :init
  (global-corfu-mode))

;;; --- File tree -------------------------------------------------------

;; Icons for the doom-themes treemacs theme ("doom-atom") set above.
;; Uses the Hack Nerd Font that is already installed in ~/Library/Fonts.
(use-package nerd-icons
  :ensure t
  :custom
  (nerd-icons-font-family "Hack Nerd Font Mono"))

(use-package treemacs
  :ensure t
  :bind
  (("s-b"   . treemacs)                 ; Cmd-b toggles the tree, like VS Code
   ("C-c t" . treemacs)                 ; same, but also works in a terminal
   ("C-c T" . treemacs-select-window))  ; jump to the tree without closing it
  :custom
  (treemacs-width 30)
  :config
  (treemacs-follow-mode t)              ; highlight the file you're editing
  (treemacs-project-follow-mode t)      ; show the project of the current buffer
  (treemacs-filewatch-mode t)           ; refresh when files change on disk
  (treemacs-git-mode 'simple))          ; colour files by git status

;;; --- Git -------------------------------------------------------------

(use-package magit
  :ensure t
  :bind
  (("C-x g"   . magit-status)          ; the standard Magit entry point
   ("s-g"     . magit-status)          ; Cmd-g, like s-b for treemacs
   ("C-c g"   . magit-dispatch)        ; menu of every Magit command
   ("C-c f"   . magit-file-dispatch))  ; actions for the current file (blame, log, ...)
  :custom
  ;; Open the status buffer in the current window instead of splitting
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; Refresh treemacs' git colours after Magit commits, stages, etc.
(use-package treemacs-magit
  :ensure t
  :after (treemacs magit))

;;; --- Discoverability: leader menu, which-key popup, rich M-x ----------

;; which-key (built into Emacs 30+): after any prefix key (C-x, C-c, the
;; leader below...) pause briefly and a popup lists every key that can
;; follow, with the command or group it runs.
(use-package which-key
  :custom
  (which-key-idle-delay 0.3)
  (which-key-sort-order #'which-key-key-order-alpha)
  :config
  (which-key-mode 1))

;; Vertico: vertical completion list for M-x, find-file, switch-buffer, ...
(use-package vertico
  :ensure t
  :init
  (vertico-mode 1))

;; Marginalia: annotate those candidates; in M-x every command shows its
;; key binding and the first line of its docstring.
(use-package marginalia
  :ensure t
  :init
  (marginalia-mode 1))

;; Orderless: match space-separated fragments in any order ("buf kill")
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion)))))

;; Remember recent M-x choices so they float to the top
(savehist-mode 1)
(recentf-mode 1)

;;; --- Leader key (Doom/Spacemacs-style SPC menu, but on M-SPC) ----------

(defvar-keymap my/leader-file-map
  "f" #'find-file
  "r" #'recentf-open
  "s" #'save-buffer
  "t" #'treemacs)

(defvar-keymap my/leader-buffer-map
  "b" #'switch-to-buffer
  "i" #'ibuffer
  "k" #'kill-current-buffer
  "r" #'revert-buffer)

(defvar-keymap my/leader-window-map
  "d" #'delete-window
  "m" #'delete-other-windows
  "o" #'other-window
  "s" #'split-window-below
  "v" #'split-window-right)

(defvar-keymap my/leader-code-map
  "a" #'eglot-code-actions
  "d" #'xref-find-definitions
  "f" #'eglot-format-buffer
  "r" #'eglot-rename
  "u" #'xref-find-references)

(defvar-keymap my/leader-git-map
  "b" #'magit-blame
  "d" #'magit-dispatch
  "f" #'magit-file-dispatch
  "s" #'magit-status)

(defvar-keymap my/leader-map
  :doc "Doom/Spacemacs-style leader menu."
  "SPC"   #'execute-extended-command  ; M-SPC SPC   -> M-x
  "M-SPC" #'execute-extended-command  ; M-SPC M-SPC -> M-x (hold Option)
  ":"     #'eval-expression
  "b"     my/leader-buffer-map
  "c"     my/leader-code-map
  "f"     my/leader-file-map
  "g"     my/leader-git-map
  "h"     help-map                    ; the built-in C-h menu
  "p"     project-prefix-map          ; the built-in C-x p menu
  "w"     my/leader-window-map)

;; Group names shown by which-key instead of "+prefix"
(which-key-add-keymap-based-replacements my/leader-map
  "b" "buffers"
  "c" "code"
  "f" "files"
  "g" "git"
  "h" "help"
  "p" "project"
  "w" "windows")

;; M-SPC is Option-Space with your Mac modifier setup. It replaces the
;; rarely used `cycle-spacing'.
(keymap-global-set "M-SPC" my/leader-map)

;;; --- Evil (Vim emulation) ---------------------------------------------

(use-package evil
  :ensure t
  :init
  ;; These must be set BEFORE evil loads, so they go in :init
  (setq evil-want-integration t       ; needed by evil-collection
        evil-want-keybinding nil      ; let evil-collection handle other modes
        evil-want-C-u-scroll t        ; C-u scrolls up like Vim (Emacs uses it for prefix args)
        evil-want-C-i-jump nil        ; in a terminal, TAB and C-i are the same key
        evil-undo-system 'undo-redo   ; Vim-like u / C-r using Emacs' built-in redo
        evil-want-fine-undo nil       ; one insert session = one undo step, like Vim
        evil-split-window-below t     ; :sp opens below
        evil-vsplit-window-right t)   ; :vs opens to the right
  :config
  (evil-mode 1)
  ;; The leader menu above on SPC in normal/visual/motion states,
  ;; so SPC f f, SPC g s, SPC w v, ... all work. M-SPC still works too.
  (evil-define-key '(normal visual motion) 'global (kbd "SPC") my/leader-map))

;; Vim-style keys for Magit, Dired, Help, Corfu, Eglot, Xref, ibuffer, ...
(use-package evil-collection
  :ensure t
  :after evil
  :config
  (evil-collection-init))

;; ys / cs / ds  (like tpope's vim-surround)
(use-package evil-surround
  :ensure t
  :after evil
  :config
  (global-evil-surround-mode 1))

;; gc / gcc to comment (like vim-commentary)
(use-package evil-commentary
  :ensure t
  :after evil
  :config
  (evil-commentary-mode 1))

;; hjkl etc. inside the Treemacs tree
(use-package treemacs-evil
  :ensure t
  :after (treemacs evil))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(doom-themes rust-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
