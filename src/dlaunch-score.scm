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

;; A wrapper around dmenu, which takes the path to a score file as a first
;; parameter and uses it to sort all lines from the current input port.
;; These lines will be piped into dmenu. The file will be updated after the
;; user selects a string. If the file does not exist, it will be created.

(declare (uses score-table score-list dmenu-wrapper))
(use ports extras)

(define program-args (command-line-arguments))
(if (null? program-args)
  (error
    (string-append
      "need at least one argument, which"
      " must be a path to a score file.")))

(define score-file-path (car program-args))
(define score-table
  (condition-case
    (score-table-read score-file-path)
    ((exn file) (make-hash-table))))

(define selected-command
  (dmenu-select-from-list
    (score-list-harvest
      (port-fold
        (lambda (str lst)
          (score-list-add lst str score-table))
        '() read-line))
    (cdr program-args)))

(if (not selected-command)
  (exit 1))

(score-table-learn! score-table selected-command)
(score-table-write score-table score-file-path)
(print selected-command)
