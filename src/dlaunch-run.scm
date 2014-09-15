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

;; Collects all commands locatable trough the environment variable 'PATH'
;; and passes them to dmenu.

(declare (uses special-paths dmenu-wrapper score-table score-list))

(use srfi-1)
(use posix)

(define paths (string-split (get-environment-variable "PATH") ":"))
(define score-file-path (get-data-file-path "dlaunch-run.scm"))
(define score-table
  (if (file-exists? score-file-path)
    (score-table-read score-file-path)
    (make-hash-table)))

; Build a score-list from all commands in 'paths'.
(define score-list
  (fold
    (lambda (path lst)
      (condition-case
        (fold
          (lambda (command lst)
            (score-list-add lst command score-table))
          lst (directory path))
        ((exn file) lst)))
    '() paths))

(define selected-command
  (dmenu-select-from-list
    (score-list-harvest score-list)
  '("-p" "run")))

(if (not selected-command)
  (exit))

(score-table-learn! score-table selected-command)
(ensure-data-dir)
(score-table-write score-table score-file-path)

(process-execute "/bin/sh" (list "-c" selected-command))
