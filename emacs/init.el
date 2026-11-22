;; -*- lexical-binding: t; -*-

;;; --- Custom configuration --------------------------------------------

;; So I can use norwegian keyboard layout
(global-set-key (kbd "≈") 'execute-extended-command)

;; Custom themes tracked in dotfiles (emacs/themes/), stowed to ~/.emacs.d/themes
(add-to-list 'custom-theme-load-path (expand-file-name "themes" user-emacs-directory))

;; Keep Custom's auto-generated settings out of this version-controlled file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror)

;; --- Turns on mouse and mouse-scroll
(unless (display-graphic-p)
  (xterm-mouse-mode 1)
  (mouse-wheel-mode 1))

;; install smex and ido-completing-read+ from MELPA first
(ido-mode 1)
(ido-everywhere 1)
;;(ido-ubiquitous-mode 1)
(global-set-key (kbd "M-x") 'smex)

;; --- Hopefully fixes my issues with Mac + Norwegian meta keys
(when (eq system-type 'darwin)
  (setq mac-option-modifier 'meta          ; left Option = Meta
        mac-right-option-modifier 'none    ; right Option = normal macOS (for @ $ { } [ ] | \)
        mac-command-modifier 'super))      ; Cmd = Super (keeps Cmd-c/Cmd-v style bindings free)

;;; --- Package setup ---------------------------------------------------

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Refresh the package list the first time, if it's empty
(unless package-archive-contents
  (package-refresh-contents))

(use-package doom-themes
  :ensure t
  :custom
  ;; Global settings (defaults)
  (doom-themes-enable-bold t)   ; if nil, bold is universally disabled
  (doom-themes-enable-italic t) ; if nil, italics is universally disabled
  :config
  (load-theme 'doom-1337 t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Treemacs icons come from treemacs-nerd-icons (works in terminal too)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

;;; --- System clipboard in terminal Emacs -------------------------------
;; GUI Emacs already shares the clipboard; in a terminal, route kills/yanks
;; through pbcopy/pbpaste so Evil's y/p and C-y talk to the macOS clipboard.
(use-package xclip
  :ensure t
  :config
  (xclip-mode 1))

;;; --- PATH for language tools ------------------------------------------

;; GUI Emacs started from the Dock doesn't get the shell's PATH,
;; so tell it where Homebrew (jdtls, kotlin-lsp, mvn) and rustup (cargo,
;; rustfmt, rust-analyzer) install binaries. Later entries take precedence.
(when (eq system-type 'darwin)
  (dolist (dir (list "/opt/homebrew/bin" (expand-file-name "~/.cargo/bin")))
    (add-to-list 'exec-path dir)
    (setenv "PATH" (concat dir path-separator (getenv "PATH")))))

;;; --- Rust ------------------------------------------------------------

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
  (eglot-connect-timeout 120)    ; jdtls/kotlin-lsp are slow on the first Maven import
  :config
  ;; Run clippy instead of `cargo check' (from the rust-analyzer manual)

  (add-to-list 'eglot-server-programs
               '((rust-ts-mode rust-mode) .
                 ("rust-analyzer" :initializationOptions (:check (:command "clippy")))))
  ;; TypeScript 7's native compiler has a built-in language server
  (add-to-list 'eglot-server-programs
               '(((typescript-ts-mode :language-id "typescript")
                  (tsx-ts-mode :language-id "typescriptreact"))
                 . ("tsc" "--lsp" "--stdio")))
  ;; JetBrains' official Kotlin server; Eglot's default (fwcd) is deprecated
  (add-to-list 'eglot-server-programs
               '((kotlin-ts-mode kotlin-mode) . ("kotlin-lsp" "--stdio"))))

;; Completion popup for the candidates Eglot provides
(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)
  :init
  (global-corfu-mode))

;;; --- TypeScript ------------------------------------------------------

;; typescript-ts-mode and tsx-ts-mode ship with Emacs. Enabling them makes
;; Emacs offer to install the tree-sitter grammar (pinned to a known-good
;; commit) the first time a .ts/.tsx file is opened.
(setopt treesit-enabled-modes '(typescript-ts-mode tsx-ts-mode java-ts-mode))

;; Start the language server in both .ts and .tsx buffers
(add-hook 'typescript-ts-base-mode-hook #'eglot-ensure)

;;; --- Java ------------------------------------------------------------

;; java-ts-mode ships with Emacs and Eglot starts jdtls for it by default.
(add-hook 'java-ts-mode-hook #'eglot-ensure)

;;; --- Kotlin ----------------------------------------------------------

(use-package kotlin-ts-mode
  :ensure t
  :mode "\\.kts?\\'"
  :init
  (add-to-list 'treesit-language-source-alist
               '(kotlin "https://github.com/fwcd/tree-sitter-kotlin"))
  :hook (kotlin-ts-mode . eglot-ensure))

;;; --- Bazel -----------------------------------------------------------

;; Major modes for BUILD, WORKSPACE, MODULE.bazel, .bzl and .bazelrc files.
;; The package registers its own auto-mode-alist entries.
(use-package bazel
  :ensure t)

;;; --- File tree -------------------------------------------------------

;; Icon font for treemacs-nerd-icons below.
;; Uses the Hack Nerd Font that is already installed in ~/Library/Fonts.
(use-package nerd-icons
  :ensure t
  :custom
  (nerd-icons-font-family "Hack Nerd Font Mono"))

(use-package treemacs
  :ensure t
  :bind
  (("s-b"   . treemacs)                 ; Cmd-b toggles the tree, like VS Code
   ("C-c T" . treemacs)                 ; same, but also works in a terminal
   ("C-c t" . treemacs-select-window))  ; jump to the tree without closing it
  :custom
  (treemacs-width 30)
  (treemacs-width-is-initially-locked nil)            ; drag the divider to resize
  (treemacs-collapse-dirs 3)                          ; show src/main/java as one row
  (treemacs-is-never-other-window t)                  ; C-x o / C-w w skip the tree
  (windmove-allow-all-windows t)                      ; ...but C-w h/j/k/l can still reach it
  (treemacs-project-follow-cleanup t)                 ; fold up projects you leave
  (treemacs-recenter-after-file-follow 'on-distance)  ; keep the current file in view
  (treemacs-sorting 'alphabetic-case-insensitive-asc) ; README next to readme.txt
  (treemacs-silent-refresh t)                         ; no "refreshed" messages
  (treemacs-silent-filewatch t)
  :config
  (treemacs-follow-mode t)              ; highlight the file you're editing
  (treemacs-project-follow-mode t)      ; show the project of the current buffer
  (treemacs-filewatch-mode t)           ; refresh when files change on disk
  (treemacs-fringe-indicator-mode 'always) ; a bar marking the current line
  (treemacs-indent-guide-mode t)        ; vertical lines showing nesting
  (treemacs-git-commit-diff-mode t)     ; "↑2 ↓1" next to the project name
  (treemacs-hide-gitignored-files-mode t) ; hide target/, node_modules/, ...
  (treemacs-git-mode 'deferred))        ; colour files and folders by git status (uses python3)

;; Colourful per-filetype icons, in GUI and terminal Emacs alike
(use-package treemacs-nerd-icons
  :ensure t
  :after treemacs
  :config
  (treemacs-load-theme "nerd-icons"))

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
