; Copyright (c) 2014 Alexander Heinrich <alxhnr@nudelpost.de>
;
; This software is provided 'as-is', without any express or implied
; warranty. In no event will the authors be held liable for any damages
; arising from the use of this software.
;
; Permission is granted to anyone to use this software for any purpose,
; including commercial applications, and to alter it and redistribute it
; freely, subject to the following restrictions:
;
;    1. The origin of this software must not be misrepresented; you must
;       not claim that you wrote the original software. If you use this
;       software in a product, an acknowledgment in the product
;       documentation would be appreciated but is not required.
;
;    2. Altered source versions must be plainly marked as such, and must
;       not be misrepresented as being the original software.
;
;    3. This notice may not be removed or altered from any source
;       distribution.

;; A wrapper around dmenu, which honors special arguments defined in
;; "dmenu-args.scm". An optional score file can be specified by the
;; "--score-file=FILE" flag. This file will be used it to sort all input
;; lines, before passing them to dmenu. If the file does not exist, it will
;; be created. It will be updated after the user selects a string. It will
;; return 1 if the user aborts his selection, or the score contains invalid
;; expressions.

(declare (uses score-table score-list dmenu-wrapper))
(use ports extras posix srfi-1 srfi-13)

(define score-file-prefix "--score-file=")

(define-values (dlaunch-args dmenu-extra-args)
  (partition
    (lambda (str)
      (string-prefix? score-file-prefix str))
    (command-line-arguments)))

;; If there is no score file specified, we can invoke dmenu directly.
(if (null? dlaunch-args)
  (process-execute "dmenu" (append dmenu-args dmenu-extra-args))
  (begin
    (define score-file-path
      (substring
        (last dlaunch-args)
        (string-length score-file-prefix)))
    (define score-table (score-table-safe-read score-file-path))
    (define selected-command
      (dmenu-select-from-list
        (score-list-harvest
          (port-fold
            (lambda (str lst)
              (score-list-add lst str score-table))
            '() read-line))
        dmenu-extra-args))
    (if (not selected-command)
      (exit 1))
    (score-table-learn! score-table selected-command)
    (score-table-write score-table score-file-path)
    (print selected-command)))
