(add-to-list 'load-path "~/.emacs.d/gavin/feature-mode")
(add-to-list 'load-path "~/.emacs.d/gavin/tabbar-1.3")
(add-to-list 'load-path "~/.emacs.d/gavin/pig-mode")
(add-to-list 'load-path "~/.emacs.d/gavin/elein")

(global-set-key [delete] 'delete-char)
(global-set-key [kp-delete] 'delete-char)

(require 'cc-mode)
(require 'ctypes)
(require 'pig-mode)
(require 'cmake-mode)
(require 'whitespace)
(require 'elein)
(setq whitespace-style '(trailing lines space-before-tab
                          indentation space-after-tab)
      whitespace-line-column 100)

;;; c++ - mode
(add-hook 'c++-mode-hook
          '(lambda ()
             (require 'font-lock)
             (setq c++-font-lock-keywords c++-font-lock-keywords-3)
             (font-lock-mode 1)
             (whitespace-mode 1)))

(add-hook 'clojure-mode-hook
          '(lambda ()
             (whitespace-mode 1)))

(defconst my-c-style
  '((c-tab-always-indent        . t)
    (c-basic-offset             . 4)
    (c-comment-only-line-offset . 0)
    (c-hanging-braces-alist     . ((substatement-open before)
                                   (substatement-open after)
                                   (brace-list-open)))
    (c-hanging-colons-alist     . ((member-init-intro before)
                                   (inher-intro)
                                   (case-label after)
                                   (label after)
                                   (access-label after)))
    (c-cleanup-list             . (scope-operator
                                   empty-defun-braces
                                   defun-close-semi))
    (c-offsets-alist            . ((arglist-close . c-lineup-arglist)
                                   (substatement-open . 0)
                                   (innamespace       . 0)
                                   (member-init-intro . +)
                                   (inline-open       . 0)
                                   (case-label        . +)
                                   (block-open        . 0)
                                   (knr-argdecl-intro . -)))
    (c-echo-syntactic-information-p . t)
    )
  "My C Programming Style")

;;offset customizations not in my-c-style
(setq c-offsets-alist (cons '(member-init-intro . ++)
                            c-offsets-alist))

;; Customizations for all modes in CC Mode.
(defun my-c-mode-common-hook ()
  ;; add my personal style and set it for the current buffer
  (c-add-style "PERSONAL" my-c-style t)
  ;; other customizations
  (setq tab-width 4
        ;; this will make sure spaces are used instead of tabs
        indent-tabs-mode nil)
  ;; we like auto-newline and hungry-delete
  (c-toggle-auto-hungry-state 1)
  ;; keybindings for all supported languages.  We can put these in
  ;; c-mode-base-map because c-mode-map, c++-mode-map, objc-mode-map,
  ;; java-mode-map, idl-mode-map, and pike-mode-map inherit from it.
  (define-key c-mode-base-map "\C-m" 'newline-and-indent)
  )

(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)

(require 'ctypes)

(autoload 'feature-mode "feature-mode" "Mode for editing cucumber files" t)

;; Go into proper mode according to file extension
(setq auto-mode-alist
      (append '(("\\.h$"            . c++-mode)
                ("\\onscript$"      . python-mode)
                ("\\onstruct$"      . python-mode)
                ("\.feature$"       . feature-mode)
                ("CMakeLists\\.txt\\'" . cmake-mode)
                ("\\.cmake\\'" . cmake-mode)
                ) auto-mode-alist))

;;(require 'feature-mode)
;;(add-to-list 'feature-mode '("\.feature$" . feature-mode))



;; ;; Vi-style parentheses matching
;; (defun match-paren (arg)
;;   "Go to the matching parenthesis if on parenthesis otherwise insert %n."
;;   (interactive "p")
;;   (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
;; 	((looking-at "\\s\)") (forward-char 1) (backward-list 1))
;; 	(t (self-insert-command (or arg 1)))))


;; Bind some keys
(global-set-key [(control meta up)] 'upcase-region)

(global-set-key [(control meta down)] 'downcase-region)

(global-set-key [(C-s)] 'isearch-forward-regexp)

(global-set-key [\C-r] 'isearch-backward-regexp)

(global-set-key [(C-down-mouse-3)] 'mouse-buffer-menu)

;; (global-set-key "%" 'match-paren)

;; minimising is annoying when I do it by accident
(global-unset-key "\C-z")

(indented-text-mode)
(auto-fill-mode 120)

;; FILL mode on/off with Shift-f4, default wrap at column 72,
;; run fill-region by hitting Shift-f3
(setq fill-column 120)
(global-set-key [(shift f3)] 'fill-region)
(global-set-key [(shift f4)] 'auto-fill-mode)
(setq-default auto-fill-function 'do-auto-fill)

;; Start some useful stuff
(mwheel-install)

(server-start)

(global-set-key [(f7)] 'compile)

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

(global-set-key [(control meta m)] 'remove-control-m-emacs)

(defun remove-control-m-emacs ()
        "Removes ^M characters."     ;; < the doc string: C-h f my-command
        (interactive)         ;; < marks this function user callable
        (replace-string "" "" nil nil nil)
)

(global-unset-key [(C-s)] )
(global-unset-key [(C-S)] )
(global-set-key [(C-s)] 'isearch-forward-regexp)
(global-set-key [(C-S)] 'isearch-backward-regexp)

(require 'prog-helpers)

(cua-selection-mode t)
(if (fboundp 'pc-selection-mode)
    (pc-selection-mode)
  (require 'pc-select))

(setq mac-command-modifier 'meta)
(global-unset-key (kbd "M-3"))
(global-set-key (kbd "M-3") '(lambda() (interactive) (insert-string "#")))

(setq frame-title-format "%S: %f")

(if window-system (color-theme-zenburn))

(require 'tabbar)

(set-face-attribute
 'tabbar-default-face nil
 :background "gray60")
(set-face-attribute
 'tabbar-unselected-face nil
 :background "gray85"
 :foreground "gray30"
 :box nil)
(set-face-attribute
 'tabbar-selected-face nil
 :background "#f2f2f6"
 :foreground "black"
 :box nil)
(set-face-attribute
 'tabbar-button-face nil
 :box '(:line-width 1 :color "gray72" :style released-button))
(set-face-attribute
 'tabbar-separator-face nil
 :height 0.7)

(tabbar-mode 1)

(define-globalized-minor-mode global-highlight-parentheses-mode
  highlight-parentheses-mode
  (lambda ()
    (highlight-parentheses-mode t)))
(global-highlight-parentheses-mode t)

(eval-after-load 'clojure-mode
  '(define-clojure-indent
     (describe 'defun)
     (testing 'defun)
     (given 'defun)
     (using 'defun)
     (with 'defun)
     (it 'defun)
     (do-it 'defun)))
