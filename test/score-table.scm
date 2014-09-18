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

(declare (uses score-table score-list))
(use test files posix srfi-1 srfi-13 srfi-69)

;; Validates a timestamp immediately after reading a score file.
(define (valid-timestamp? timestamp)
  (and (flonum? timestamp)
       (>= timestamp 0)
       (<= timestamp (local-time->seconds (seconds->local-time)))))

;; A list of paths to broken score files, which are relative to the project
;; root directory.
(define broken-score-file-list
  (map
    (lambda (str) (string-append "test/misc/" str))
    (filter
      (lambda (str)
        (string-prefix? "broken-score-file-" str))
      (directory "test/misc/"))))

;; Returns the first element in 'lst', that does not result in an error,
;; when thunk is applied on it. If will return #f, if nothing was found.
(define (find-errorless-element thunk lst)
  (find
    (lambda (filename)
      (condition-case
        (begin (thunk filename) #t)
        ((exn) #f))) lst))

;; This test asserts that all calls of 'thunk' on each element in
;; 'broken-score-file-list' result in an error.
(define (broken-score-file-test thunk)
  (test "Reject broken score files" #f
        (find-errorless-element
          thunk broken-score-file-list)))

;; A simple test, that asserts 'thunk' to load score files.
(define (test-score-file-read-fun thunk)
  (test
    "Reading an empty score table" '()
    (hash-table->alist
      (thunk "test/misc/empty-score-table.scm")))
  (define some-score-file "test/misc/some-score-list.scm")
  (test
    (string-append "Reading and sorting \"" some-score-file "\"")
    '("this" "test" "was" "successful")
    (map
      car
      (score-list-sort
        (hash-table->alist
          (thunk some-score-file))))))

(test-begin "score-table")

;; This must be a sorted a-list, descending by score and should not be
;; mutated during runtime.
(define dummy-score-list
  '(("Toast"   . 123.456)
    ("CHICKEN" . 3.0)
    ("Scheme"  . 2.0)
    ("Tomato"  . 0.75)))

(test-group
  "score-table-read"
  (test-score-file-read-fun score-table-read)
  (broken-score-file-test score-table-read)
  (test-error
    "Reject non-existing files"
    (score-table-read "test/misc/non-existent-file.scm")))

(test-group
  "score-table-safe-read"
  (test-score-file-read-fun score-table-read)
  (test
    "Allowing non-existing files" '()
    (hash-table->alist
      (score-table-safe-read "test/misc/non-existent-file.scm"))))

(test-group
  "score-table-write"

  (define tmpfile "test/tmp/dummy-score-table.scm")

  ; Write and read the dummy-score-list.
  (score-table-write (alist->hash-table dummy-score-list) tmpfile)
  (define tmpfile-content (read-file tmpfile))
  (test-assert
    "Validate timestamp"
    (valid-timestamp? (car tmpfile-content)))
  (test "Validate sorting" dummy-score-list (cadr tmpfile-content))

  ; Overwrite and read the tmpfile with an empty score table.
  (score-table-write (make-hash-table) tmpfile)
  (define empty-tmpfile-content (read-file tmpfile))
  (test-assert
    "Validate timestamp from empty file"
    (valid-timestamp? (car empty-tmpfile-content)))
  (test "Validate a-list in empty file" '() (cadr empty-tmpfile-content)))

(test-group
  "score-table-learn!"
  (define dummy-score-table (make-hash-table))
  (score-table-learn! dummy-score-table "CHICKEN")
  (score-table-learn! dummy-score-table "CHICKEN")
  (score-table-learn! dummy-score-table "CHICKEN")
  (score-table-learn! dummy-score-table "Scheme")
  (score-table-learn! dummy-score-table "Scheme")
  (score-table-learn! dummy-score-table "Tomato" 0.5)
  (score-table-learn! dummy-score-table "Tomato" 0.25)
  (score-table-learn! dummy-score-table "Toast" 123.456)
  (test
    "Create sorted score list from learned strings"
    dummy-score-list
    (score-list-sort (hash-table->alist dummy-score-table))))

(test-end)
(test-exit)
