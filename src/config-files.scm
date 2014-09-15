;; This unit helps to manage config paths and files.
(declare (unit config-files)
  (export get-config-file-path
          ensure-config-dir))

(define config-dir-path
  (string-append (get-environment-variable "HOME")
                 "/.config/dlaunch-tools/"))

(define (get-config-file-path filename)
  (string-append config-dir-path filename))

(define (ensure-config-dir)
  (create-directory config-dir-path #t))
