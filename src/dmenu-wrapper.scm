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

;; This unit provides a wrapper around dmenu. It reads arguments
;; from "dmenu-args.scm" and passes them to dmenu.

(declare (unit dmenu-wrapper)
  (uses special-paths misc)
  (export dmenu-args
          dmenu-select
          dmenu-select-from-list))

(use extras)
(use posix)

(define dmenu-args
  (begin
    (define arg-file-path (get-config-file-path "dmenu-args.scm"))
    (if (file-exists? arg-file-path)
      (car (read-file-or-die arg-file-path))
      '())))

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
