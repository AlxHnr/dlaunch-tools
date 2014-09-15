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
