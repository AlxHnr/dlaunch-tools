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

;; Collects all commands in 'PATH' and passes them to dmenu. Custom
;; commands can be added to the config file "dlaunch-run.scm". This config
;; file can contain lists of strings (commands), which will be listed in
;; dmenu. The config file can also contain pairs. A pair associates a
;; custom command with a real command. The custom command will appear in
;; dmenus listing, while the real command will be executed.

(declare (uses special-paths dmenu-wrapper score-table score-list))
(use srfi-1 srfi-69 extras posix)

(define custom-command-file (get-config-file-path "custom-commands.scm"))
(define score-file-path (get-data-file-path "dlaunch-run.scm"))
(define score-table
  (if (file-exists? score-file-path)
    (score-table-read score-file-path)
    (make-hash-table)))

; Decomposes the content of "dlaunch-run.scm" into a hash table and a score
; list. The hash table contains the associations and the list contains the
; strings and its scores.
(define custom-command-table (make-hash-table))
(define custom-command-scores
  (fold
    (lambda (list-item lst)
      (if (list? list-item)
        (fold
          (lambda (str lst)
            (score-list-add lst str score-table))
          lst list-item)
        (begin
          (hash-table-set!
            custom-command-table
            (car list-item)
            (cdr list-item))
          (score-list-add lst (car list-item) score-table))))
    (list)
    (if (file-exists? custom-command-file)
      (condition-case
        (read-file custom-command-file)
        ((exn syntax)
         (error
           (string-append "broken config file: " custom-command-file))))
      (list))))

; Build our score list from 'custom-commands-scores' and all commands
; locatable trough the environment variable 'PATH'.
(define score-list
  (fold
    (lambda (path lst)
      (condition-case
        (fold
          (lambda (command lst)
            (score-list-add lst command score-table))
          lst (directory path))
        ((exn file) lst)))
    custom-command-scores
    (string-split (get-environment-variable "PATH") ":")))

; Let the user input a string.
(define selected-command
  (dmenu-select-from-list
    (score-list-harvest score-list)
    '("-p" "run")))

(if (not selected-command)
  (exit))

(score-table-learn! score-table selected-command)
(ensure-data-dir)
(score-table-write score-table score-file-path)

; Check if the command appears in the custom-command-table and run the
; command via "/bin/sh".
(process-execute "/bin/sh" (list "-c" (hash-table-ref/default
                                        custom-command-table
                                        selected-command
                                        selected-command)))
