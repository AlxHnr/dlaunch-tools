;; This unit helps to manages config paths and files.
(declare (unit config-files)
  (export get-config-file-path))

(define conf-path
  (string-append (get-environment-variable "HOME")
                 "/.config/dlaunch-tools/"))

(define (get-config-file-path filename)
  (string-append conf-path filename))
