;; This unit helps to manage special paths and files and respects path
;; environment variables specified by the XDG Base Directory Specification.
(declare (unit special-paths)
  (export get-config-file-path
          get-data-file-path
          get-cache-file-path
          ensure-data-dir
          ensure-config-dir
          ensure-cache-dir))
(use files)

;; Determines a path from the environment. 'xdg-var-name' is an uppercase
;; string, that will be placed between "XDG_" and "_HOME" before being
;; requested from the environment. If its not available, it will fallback
;; to a specified string, which will be appended to the home path of the
;; user, and then postfixed by "/dlaunch-tools/".
(define (build-path-from-env xdg-var-name fallback-string)
  (define xdg-path
    (get-environment-variable
      (string-append "XDG_" xdg-var-name "_HOME")))
  (if (and xdg-path
           (> (string-length xdg-path) 0)
           (absolute-pathname? xdg-path))
    xdg-path
    (string-append
      (get-environment-variable "HOME") "/"
      fallback-string
      "/dlaunch-tools/")))

;; Contains various paths to special user directories.
(define config-dir-path (build-path-from-env "CONFIG" ".config"))
(define data-dir-path   (build-path-from-env "DATA"   ".local/share"))
(define cache-dir-path  (build-path-from-env "CACHE"  ".cache"))

;; Functions that prefix 'filename' with a special path.
(define (get-config-file-path filename)
  (string-append config-dir-path filename))
(define (get-data-file-path filename)
  (string-append data-dir-path filename))
(define (get-cache-file-path filename)
  (string-append cache-dir-path filename))

;; Ensures that dlaunch's special directories exists. These functions are
;; supposed to be called before creating new files in a special directory.
(define (ensure-config-dir) (create-directory config-dir-path #t))
(define (ensure-data-dir)   (create-directory data-dir-path   #t))
(define (ensure-cache-dir)  (create-directory cache-dir-path  #t))
