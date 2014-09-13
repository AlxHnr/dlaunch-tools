;; This unit provides a wrapper around dmenu, which parses "dmenu-args",
;; passes the right arguments to dmenu and handles all the pipes and
;; processes.
(declare (unit dmenu-wrapper)
  (uses helper-functions config-files)
  (export dmenu-args dmenu-select
          dmenu-select-from-list))

(use extras posix)

(define dmenu-args
  (call-with-input-file
    (get-config-file-path "dmenu-args.scm")
    read))

;; This function wraps dmenu. 'write-fun' should take an output port to
;; write lines to dmenu. After that the user can select one line or even
;; input his own text. This string will be returned on success. Otherwise
;; #f will be returned.
(define (dmenu-select write-fun)
  (define-values (dmenu-in dmenu-out dmenu-pid)
    (process "dmenu" dmenu-args))
  (write-fun dmenu-out)
  (close-output-port dmenu-out)
  (define selected-string (read-line dmenu-in))
  (close-input-port dmenu-in)
  (if (eof-object? selected-string)
    #f selected-string))

;; Takes a list of strings, prompts the user and returns either the
;; selected string or false. The user may even input his own string.
(define (dmenu-select-from-list lst)
  (dmenu-select
    (lambda (out)
      (for-each
        (lambda (str) (write-line str out))
        lst))))
