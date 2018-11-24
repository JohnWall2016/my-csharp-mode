(require 'cc-mode)

(defconst cs-keywords
  '("abstract"
    "as"
    "base"
    "bool"
    "break"
    "byte"
    "case"
    "catch"
    "char"
    "checked"
    "class"
    "const"
    "continue"
    "decimal"
    "default"
    "delegate"
    "do"
    "double"
    "else"
    "enum"
    "event"
    "explicit"
    "extern"
    "false"
    "finally"
    "fixed"
    "float"
    "for"
    "foreach"
    "goto"
    "if"
    "implicit"
    "in"
    "int"
    "interface"
    "internal"
    "is"
    "lock"
    "long"
    "namespace"
    "new"
    "null"
    "object"
    "operator"
    "out"
    "override"
    "params"
    "private"
    "protected"
    "public"
    "readonly"
    "ref"
    "return"
    "sbyte"
    "sealed"
    "short"
    "sizeof"
    "stackalloc"
    "static"
    "string"
    "struct"
    "switch"
    "this"
    "throw"
    "true"
    "try"
    "typeof"
    "uint"
    "ulong"
    "unchecked"
    "unsafe"
    "ushort"
    "using"
    "using static"
    "virtual"
    "void"
    "volatile"
    "while"
;; Contextual Keywords
    "add"
    "alias"
    "ascending"
    "async"
    "await"
    "by"
    "descending"
    "dynamic"
    "equals"
    "from"
    "get"
    "global"
    "group"
    "into"
    "join"
    "let"
    "nameof"
    "on"
    "orderby"
    "partial"
    "remove"
    "select"
    "set"
    "value"
    "var"
    "when"
    "where"
    "yield"))

(defconst cs-types '())
(defconst cs-constants '())
(defconst cs-events '())
(defconst cs-functions '())

(defconst cs-keywords-regexp (regexp-opt cs-keywords 'words))
(defconst cs-type-regexp (regexp-opt cs-types 'words))
(defconst cs-constant-regexp (regexp-opt cs-constants 'words))
(defconst cs-event-regexp (regexp-opt cs-events 'words))
(defconst cs-functions-regexp (regexp-opt cs-functions 'words))

(defconst cs-font-lock-keywords
  `((,cs-type-regexp . font-lock-type-face)
    (,cs-constant-regexp . font-lock-constant-face)
    (,cs-event-regexp . font-lock-builtin-face)
    (,cs-functions-regexp . font-lock-function-name-face)
    (,cs-keywords-regexp . font-lock-keyword-face)))

(defgroup csharp nil
  "Major mode for csharp source files."
  :group 'languages)

(defcustom cs-indent-offset 4
  "Indentation offset for `csharp-mode'."
  :type 'integer
  :group 'csharp)

(defconst cs-white-space "[ \t\n\f\v\r]")

(defun cs-indent-line ()
  "Indent current line for `csharp-mode'."
  (interactive)
  (let ((indent-col 0)
        (pos (- (point-max) (point))))
    (save-excursion
      (beginning-of-line)
      (condition-case nil
          (while t
            (backward-up-list 1)
            (when (looking-at "[{]")
              (setq indent-col (+ indent-col cs-indent-offset))))
        (error nil)))
    (save-excursion
      (back-to-indentation)
      (when (and (looking-at "[}]") (>= indent-col cs-indent-offset))
        (setq indent-col (- indent-col cs-indent-offset))))
    (save-excursion
      (back-to-indentation)
      (if (and (looking-back (concat "^" cs-white-space "*"
                                     "\\(if\\|else\\|for\\|foreach\\|while\\)"
                                     cs-white-space "*" "[^{;]*" cs-white-space "*")
                             nil)
               (not (looking-at "{")))
        (setq indent-col (+ indent-col cs-indent-offset))))
    (indent-line-to indent-col)
    (if (> (- (point-max) pos) (point))
	  (goto-char (- (point-max) pos)))))

(defvar cs-syntax-table
  (let ((synTable (make-syntax-table)))
    
    ;; // /**/
    (modify-syntax-entry ?\/ ". 124" synTable)
    (modify-syntax-entry ?\n ">" synTable)
    (modify-syntax-entry ?* ". 23b" synTable)

    (modify-syntax-entry ?' "\"" synTable)

    synTable)
  "Syntax table for `csharp-mode'.")

(defvar csharp-mode-map (let ((map (make-keymap)))
                          ;; Add bindings which are only useful for C#
                          map)
  "Keymap used in ‘csharp-mode’ buffers.")

;;;###autoload
(define-derived-mode csharp-mode text-mode "csharp"
  "Major mode for editing csharp files.

Key bindings:
\\{csharp-mode-map}"
  (setq-local indent-line-function 'cs-indent-line)
  (setq-local comment-start "//")
  (set-syntax-table cs-syntax-table)
  (setq font-lock-defaults '((cs-font-lock-keywords))))

(provide 'csharp-mode)
