(require 'cc-mode)
(require 'hippie-exp)

;; Function to eliminate trailing white space at the ends of lines. Doesn't eliminate space on
;; current line to ensure the cursor doesn't move
(defun eliminate-trailing-spaces ()
  "Eliminate whitespace at ends of lines."
  (interactive)
  (save-excursion
    (let ((oldline (count-lines (window-start) (point))))
      (goto-char (point-min))
      (while (re-search-forward "[ \t]+$" nil t)
    (if (/= oldline (count-lines (window-start) (point)))
        (delete-region (match-beginning 0) (point))))
      ))
  )

;; function for expanding abbrevs and dabbrevs
(defun cc-mode-expand-abbrev (arg))
(fset 'cc-mode-expand-abbrev (make-hippie-expand-function
               '(try-expand-dabbrev
;              ebrowse-tags-complete-symbol
              try-expand-dabbrev-all-buffers)))

;; function for expanding parenthesis
(defun cc-mode-expand-paren (arg))
(fset 'cc-mode-expand-paren (make-hippie-expand-function
              '(try-expand-list
                try-expand-list-all-buffers)))


(defun cc-mode-electric-tab (&optional prefix-arg)
  "If preceeding character is part of a word or a paren then hippie-expand,
else if right of non whitespace on line then insert tab,
else if last command was a tab or return then dedent one step or if a comment
toggle between normal indent and inline comment indent,
else indent `correctly'."
  (interactive "*P")
   (cond
    ;; expand word or symbol
    ((or (= (char-syntax (preceding-char)) ?w)
             (= (char-syntax (preceding-char)) ?_))
     (let ((case-fold-search t)
       (case-replace nil)
       (hippie-expand-only-buffers
        (or (and (boundp 'hippie-expand-only-buffers)
             hippie-expand-only-buffers)
           (quote (c-mode c++-mode cc-mode)))))
       (cc-mode-expand-abbrev prefix-arg)))
    ;; expand parenthesis
    ((or (= (preceding-char) ?\() (= (preceding-char) ?\)))
     (let ((case-fold-search t)
           (case-replace nil))
       (cc-mode-expand-paren prefix-arg)))
    ;; insert tab
    ((> (current-column) (current-indentation))
     (insert-tab))
    ;; toggle comment indent
    ((and (looking-at "//")
      (eq last-command 'cc-mode-electric-tab))
     (cond ((= (current-indentation) 0) ; no indent
        (indent-to 1)
        (indent-according-to-mode))
       ((< (current-indentation) comment-column) ; normal indent
        (indent-to comment-column)
        (indent-according-to-mode))
       (t                ; inline comment indent
        (kill-line -0))))
    ;; dedent
    ((and (>= (current-indentation) c-basic-offset)
      (eq last-command 'cc-mode-electric-tab))
     (backward-delete-char-untabify c-basic-offset nil))
    ;; indent line
    (t (indent-according-to-mode)))
   (setq this-command 'cc-mode-electric-tab));;)

;(defun rr-asm-newline ()
;  "Insert LFD + fill-prefix, to bring us back to code-indent level."
;  (interactive)
;;  (if (eolp) (delete-horizontal-space))
;  (insert "\n")
;  (indent-relative)
;  )

;(defun force_indent_fal1202 ()
;    (if (string-match "fal1202/dsp/source" buffer-file-name)
;        (function (lambda ()
;                    (c-basic-offset . 4))
;                    (setq '(tab-width 4)))))

;(defun force_reformat_fal1202 ()
;    (if (string-match "fal1202/dsp/source" buffer-file-name)
;        (progn
;          (untabify (point-min) (point-max))
;          (indent-region (point-min) (point-max) nil))))

;(defun force_clean_lines_fal1202 ()
;    (if (string-match "fal1202/dsp/source" buffer-file-name)
;        (progn
;          (eliminate-trailing-spaces))))

;(defun force_tab_w8 ()
;  (if (or (string-match "/kernel/" buffer-file-name)
;          (string-match "/DSR_FreeBSD3.3/" buffer-file-name)
;          (string-match "/piconet/" buffer-file-name))
;      (progn
;        (setq tab-width 8))))

;(defun correct-c-header-define( buf )
;  (interactive "b")
;  (save-excursion
;    (set-buffer buf)
;    (if (string-match "\\.\\(hpp\\|h\\|\hh\\|H\\)$" (buffer-name))
;        (let* ((bufname (buffer-name))
;               (defname (concat (upcase (file-name-sans-extension bufname)) "_"
;                                (upcase (file-name-extension bufname))))
;               (defstring (concat
;                           "#ifndef " defname "\n"
;                           "#define " defname "\n"))
;               (endstring (concat "#endif // " defname)))
;          (beginning-of-buffer)
;          (if (search-forward-regexp (concat "^#ifndef[ \t]+\\([a-zA-Z_][a-zA-Z0-9_]*\\)[ \t]*[\n]"
;                                             "#define[ \t]+\\([a-zA-Z_][a-zA-Z0-9_]*\\)[ \t]*[\n]")
;                                     nil t)
;              (replace-match defstring t t)
;            (progn
;              (beginning-of-buffer)
;              (insert defstring)))
;          (if (search-forward-regexp "^#endif[ \t]*//[ \t]*[a-zA-Z_][a-zA-Z0-9_]*[ \t]*$" nil t)
;              (replace-match endstring t t)
;            (progn
;              (end-of-buffer)
;              (insert endstring)))))))

;; add a string in front of all lines in the region
(defun ewd-prepend (start end s)
  "Add a string in front of all lines in the region."
  (interactive "*r\nMEnter a string: ")
  (save-excursion
    (save-restriction
      (narrow-to-region
       (progn (goto-char start) (beginning-of-line) (point))
       (progn (goto-char end) (end-of-line) (point)))
      (goto-char (point-min))
      (beginning-of-line)
      (while (not (eobp))
        (insert s)
        (forward-line 1)))))

;; add a comment character in front of all lines in the region
(defun ewd-comment-region (start end)
  "Add one comment character in front of all lines in
the region."
  (interactive "*r")
  (or comment-start (setq comment-start (read-input "Comment char?: ")))
  (ewd-prepend start end comment-start))


;(require 'newcomment)

;;; comment and tag all lines in the region
;(defun rr-comment-and-tag-region (start end)
;  "Add a tag before the first and after the last comment
;and add a comment string in front of all lines in the region"
;  (interactive "*r")
;  (save-excursion
;  (let* ((tagdatestr (concat (upcase (user-login-name)) ":" (format-time-string "%d%b%y" (current-time))))
;         ;; was "<<" tagdatestr, but this looks like a herefile to sh.
;         (tagstart (concat ">>>" tagdatestr "\n"))
;         (tagend   (concat "<<<" tagdatestr)))
;    (save-restriction
;      (narrow-to-region
;       (progn (goto-char start) (beginning-of-line) (point))
;       (progn (goto-char end) (end-of-line) (point)))
;      (goto-char (point-max)) (insert "\n") (insert tagend)
;      (goto-char (point-min)) (beginning-of-line) (insert tagstart)
;      (comment-region (point-min) (point-max))
;      ))))

;(global-set-key "\C-c;" 'rr-comment-and-tag-region)

(defvar project-normal-name-match "|||")
(defvar project-downcase-name-match "!!!")
(defvar project-upcase-name-match "@@@")

;; If you create a file called Test.hpp, this function will replace:
;;
;;   @@@ with TEST
;;   ||| with Test
;;   !!! with test
;;
;; The first one is useful for #ifdefs, the second one for the header
;; description, for example.
;(defun auto-update-header-file ()
;      (let ()
;     (save-excursion
;       (while (search-forward project-upcase-name-match nil t)
;         (save-restriction
;           (narrow-to-region (match-beginning 0) (match-end 0))
;           (replace-match
;            (upcase
;         (file-name-sans-extension
;          (file-name-nondirectory buffer-file-name)))))))
;     (save-excursion
;       (while (search-forward project-normal-name-match nil t)
;         (save-restriction
;           (narrow-to-region (match-beginning 0) (match-end 0))
;           (replace-match
;            (file-name-sans-extension
;         (file-name-nondirectory buffer-file-name))))))
;     (save-excursion
;       (while (search-forward project-downcase-name-match nil t)
;         (save-restriction
;           (narrow-to-region (match-beginning 0) (match-end 0))
;           (replace-match
;            (downcase
;         (file-name-sans-extension
;          (file-name-nondirectory buffer-file-name)))))))
;    (save-excursion
;      (while (search-forward "\<date\>" nil t)
;        (save-restriction
;          (narrow-to-region (match-beginning 0) (match-end 0))
;          (replace-match (format-time-string "%c" (current-time))))))
;    (save-excursion
;      (while (search-forward "\<real-name\>" nil t)
;        (save-restriction
;          (narrow-to-region (match-beginning 0) (match-end 0))
;          (replace-match user-full-name))))
;    (save-excursion
;      (while (search-forward "\<login-name\>" nil t)
;        (save-restriction
;          (narrow-to-region (match-beginning 0) (match-end 0))
;          (replace-match user-login-name))))
;   ))

;(defun rjr-template-field (prompt &optional follow-string optional
;                   begin end is-string default)
;  "Prompt for string and insert it in buffer with optional FOLLOW-STRING.
;If OPTIONAL is nil, the prompt is left if an empty string is inserted.  If
;an empty string is inserted, return nil and call `delete-region' for
;the region between BEGIN and END.  IS-STRING indicates whether a string
;with double-quotes is to be inserted.  DEFAULT specifies a default string."
;  (let ((position (point))
;    string)
;    (insert "<" prompt ">")
;    (setq string
;      (condition-case ()
;          (read-from-minibuffer (concat prompt ": ")
;                    (or (and is-string '("\"\"" . 2)) default)
;                    minibuffer-local-map)
;        (quit (if (and optional begin end)
;              (progn (beep) "")
;            (keyboard-quit)))))
;    (when (or (not (equal string "")) optional)
;      (delete-region position (point)))
;    (when (and (equal string "") optional begin end)
;      (delete-region begin end)
;      (message "Template aborted"))
;    (unless (equal string "")
;      (insert string))
;    (when (or (not (equal string "")) (not optional))
;      (insert (or follow-string "")))
;    (if (equal string "") nil string)))


(setq c-argument-list-indent nil)

(defun rjr-comment-insert-inline (&optional string always-insert)
  "Insert inline comment."
  (when (or (and string (or nil always-insert))
        (and (not string) t))
    (let ((position (point)))
      (insert "  ")
      (indent-to comment-column)
      (insert "// ")
      (if (not (or (and string (progn (insert string) t))
           (rjr-template-field "[comment]" nil t)))
      (delete-region position (point))
    (while (= (preceding-char) ? ) (delete-backward-char 1))
;     (when (> (current-column) end-comment-column)
;       (setq position (point-marker))
;       (re-search-backward "-- ")
;       (insert "\n")
;       (indent-to comment-column)
;       (goto-char position))
    ))))

;(defun rjr-template-argument-list (comment_point is_fn)
;  "Read from user a function argument list."
;  (let ((margin (current-column))
;    (start (point))
;    (end-pos (point))
;    not-empty argument split_args lines_fwd name semi_comma)
;   (if is_fn (setq semmi_comma ",") (setq semmi_comma ";"))
;   (setq lines_fwd (if is_fn 2 3))
;   (while (setq argument (rjr-template-field "[argument]" semmi_comma t))
;     (setq split_args (split-string argument "[ \f\t\n\*]+"))
;     (setq name ( car (last split_args)))
;      (if (or c-argument-list-indent (not is_fn))
;          (progn (insert "\n")
;                 (indent-according-to-mode)
;                 (setq lines_fwd (1+ lines_fwd)))
;        (insert " " ))
;      (goto-char comment_point)
;      (insert "\n * @" name ": ")
;      (rjr-template-field "[Argument desc]" nil t)
;      (setq comment_point (point))
;      (forward-line lines_fwd)
;      (end-of-line)
;      (backward-char 1))
;   (delete-backward-char 2)
;   (if (and is_fn c-argument-list-indent)
;       (delete-backward-char margin)
;     (if (not is_fn) (progn
;       (beginning-of-line)
;       (kill-line)
;       )))
;   (forward-line (* (- lines_fwd 2) -1))
;   (if (and is_fn c-argument-list-indent) (forward-line 1))
;   (beginning-of-line)
;   ))


;(defun rjr-template-kernel-fn_struct (is_fn)
;  "Insert a kernel-doc instrumented function or struct"
;  (let ((margin (current-indentation))
;        (start (point))
;        fname comment_point fn_point input-signals clock reset final-pos)
;    (if (not is_fn) (insert "struct "))
;    (setq fname (rjr-template-field "[Name]" nil t))
;    (if is_fn
;        (progn
;          (insert "()\n{\n\n}")
;          (forward-line -3))
;      (progn
;        (insert" {\n\n};")
;        (forward-line -2)))
;    (insert "/**\n * ")
;    (setq comment_point (point))
;    (insert "\n */\n")
;    (goto-char comment_point)
;    (if (not is_fn) (insert "struct "))
;    (insert fname " - ")
;    (if (not (rjr-template-field "[Purpose]" nil t))
;        (delete-char 3))
;    (setq comment_point (point))
;    (if is_fn (progn
;                (forward-line 2)
;                (end-of-line)
;                (backward-char 1))
;      (progn
;        (forward-line 3)
;        (beginning-of-line)
;        (indent-according-to-mode)))           
;    ;; now have:
;    ;; function_name
;    ;; Insert the arguments
;    (rjr-template-argument-list comment_point is_fn)
;    (if is_fn
;        (progn
;          ;; Insert the return type
;          (rjr-template-field "[return type]" " " t))
;      ;; insert the Context field etc...
;      )
;    (beginning-of-line)
;    (forward-line -1)
;    (insert " *\n * \n")
;    (backward-char 1)
;    (if (not rjr-template-field "[Description]" nil t)
;        (progn (forward-line -2) (kill-line 2)))
;    ))


;(defun rjr-template-kernel_struct ()
;  "Insert a kernel source structure."
;;; /**
;;;  * struct name - struct purpose
;;;  * @member1: member1 description
;;;  * @membern: membern description
;;;  *
;;;  * Description: Big description
;;;  */
;  (interactive)
;  (rjr-template-kernel-fn_struct nil))

;(defun rjr-template-kernel_fn ()
;  "Insert a kernel source function."
;;; /**
;;;  * fname - function purpose
;;;  * @arg1: arg1 description
;;;  * @argn: argn description
;;;  * Context:
;;;  *
;;;  * Description: Big description
;;;  */

;  (interactive)
;  (rjr-template-kernel-fn_struct t))

;(add-hook 'c-mode-common-hook
;      (function (lambda ()
;            (setq show-trailing-whitespace t)
;            (setq whitespace-auto-cleanup t))))

;(add-hook 'vhdl-mode-hook
;      (function (lambda ()
;            (setq show-trailing-whitespace t)
;            (setq whitespace-auto-cleanup t))))

;(add-hook 'vhdl-mode-hook
;          '(lambda ()
;             (add-hook 'write-contents-hooks 'eliminate-trailing-spaces)))

;;; replace the c-indent-command command with cc-mode-electric tab
(add-hook 'c-mode-common-hook
          '(lambda()
             (substitute-key-definition 'c-indent-command 'cc-mode-electric-tab c-mode-base-map)))

;;; Override the annoying asm-mode comment behaviour
;(add-hook 'asm-mode-hook
;      (function (lambda()
;             (local-unset-key (vector asm-comment-char))
;             (local-unset-key [C-i])
;             (setq show-trailing-whitespace t)
;             (setq whitespace-auto-cleanup t)
;             (add-hook 'write-contents-hooks 'eliminate-trailing-spaces)
;             (setq indent-tabs-mode t)
;             (setq tab-width 8)
;             (set (make-local-variable 'comment-continue) ";;")
;             (substitute-key-definition 'asm-newline 'rr-asm-newline asm-mode-map))))

;;;(global-ede-mode t)

;(add-hook 'c-mode-common-hook
;          ( function (lambda ()
;                       (force_tab_w8))))

;;(add-hook 'c-mode-common-hook
;;      (function (lambda ()
;;            (force_reformat_fal1202))))

;;(add-hook 'c-mode-common-hook
;;      (function (lambda ()
;;            (force_indent_fal1202))))

;;; cc-mode
;;;   Case sensitive search
;;;   No white space at eol
;(add-hook 'c-mode-common-hook
;          '(lambda ()
;             (add-hook 'write-contents-hooks 'eliminate-trailing-spaces)))

;(font-lock-add-keywords
; 'c-mode
; '(("\\<\\(RJR\\)" 1 font-lock-warning-face t)
;   ("\\<\\(FIXME\\):" 1 font-lock-warning-face t)
;   ("^//[     ]*\\RJR[     ]*\\(<[^>\"\n]*>?\\)" 1 font-lock-warning-face t)))

;(font-lock-add-keywords
; 'c++-mode
; '(("\\<\\(RJR\\)" 1 font-lock-warning-face t)
;   ("\\<\\(FIXME\\):" 1 font-lock-warning-face t)
;   ("^//[     ]*\\RJR[     ]*\\(<[^>\"\n]*>?\\)" 1 font-lock-warning-face t)))


;;; Auto-insert for a bunch of file extensions
;(add-hook 'find-file-hooks 'auto-insert)

;(global-set-key [f11] '(lambda ()
;             (interactive)
;             (correct-c-header-define (current-buffer))))

;(setq auto-insert-alist (quote
;(("\\main.cpp$" .
;  ["main.cpp" auto-update-header-file])
; ("\\main.cc$" .
;  ["main.cc" auto-update-header-file])
; ("\\.cpp$" .
;  ["cpp" auto-update-header-file])
; ("\\.cc$" .
;  ["cc" auto-update-header-file])
; ("\\.c$" .
;  ["c" auto-update-header-file])
; ("\\.hpp$" .
;  ["hpp" auto-update-header-file])
; ("\\.hh$" .
;  ["hh" auto-update-header-file])
; ("\\.h$" .
;  ["h" auto-update-header-file]))))

(provide 'prog-helpers)
