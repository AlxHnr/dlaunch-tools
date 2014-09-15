;; This unit provides a wrapper around dmenu. It reads arguments
;; from "dmenu-args.scm" and passes them to dmenu.
(declare (unit dmenu-wrapper)
  (uses special-paths)
  (export dmenu-args
          dmenu-select
          dmenu-select-from-list))

(use extras)
(use posix)

(define dmenu-args
  (call-with-input-file
    (get-config-file-path "dmenu-args.scm")
    read))

;; This function wraps dmenu. 'write-fun' should take an output port to
;; write lines to dmenu. On success, the input of the user will be returned
;; as a string. Otherwise #f will be returned. This function takes an
;; optional second parameter, which is a list of strings, that will be
;; passed to dmenu additionally to the args specified in "dmenu-args.scm".
(define (dmenu-select write-fun #!optional (extra-args '()))
  (define-values (dmenu-in dmenu-out dmenu-pid)
    (process "dmenu" (append dmenu-args extra-args)))
  (write-fun dmenu-out)
  (close-output-port dmenu-out)
  (define selected-string (read-line dmenu-in))
  (close-input-port dmenu-in)
  (if (eof-object? selected-string)
    #f selected-string))

;; Takes a list of strings, prompts the user and returns either the
;; selected string or false. The user may even input his own string.
;; This function takes an optional second parameter, which is a list of
;; strings that are passed as extra arguments to dmenu.
(define (dmenu-select-from-list lst #!optional (extra-args '()))
  (dmenu-select
    (lambda (out)
      (for-each
        (lambda (str) (write-line str out))
        lst))
    extra-args))
