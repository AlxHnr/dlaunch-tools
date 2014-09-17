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

;; This unit provides an interface between a score-file and a score-table.
;; Such a score file has a very simple structure: it is a simple scheme
;; file containing a floating point value followed by an associative list.
;; The floating point value represents the time in seconds of the last
;; scoring. The a-list associates a string with its score. Scores are
;; floating point values, which decrease continuously. The time needed for
;; a score to decrease by 1 is specified in seconds in the variable
;; 'score-decay-interval'. This decrease is applied transparently by the
;; function 'score-table-read'.

(declare (unit score-table)
  (uses score-list)
  (export score-table-read
          score-table-safe-read
          score-table-write
          score-table-learn!))

(use srfi-69)
(use posix)

(define score-decay-interval (* 60 60 24 1.5))

;; This function reads an existing score file, as described above, and
;; returns a hash-table which associates a string with its score. It
;; re-scores the a-list using the timestamp specified in the file. This
;; function does not handle errors, thus syntax or file exceptions may be
;; raised.
(define (score-table-read filename)
  (define score-file-content (read-file filename))
  (define score-list (cadr score-file-content))
  (define score-decay
    (/ (abs (- (local-time->seconds (seconds->local-time))
               (car score-file-content)))
       score-decay-interval))
  (define table (make-hash-table))
  (for-each
    (lambda (score-pair)
      (define new-score (- (cdr score-pair) score-decay))
      (if (> new-score 0.0)
        (hash-table-set! table (car score-pair) new-score)))
    score-list)
  table)

;; Like 'score-table-read', but with two differences: If the file does not
;; exist, it returns an empty hash-table. If the file exists and is broken,
;; it will message an error and terminate the program.
(define (score-table-safe-read filename)
  (if (file-exists? filename)
    (condition-case
      (score-table-read filename)
      ((exn syntax)
       (print-error-message
         (string-append "Broken score file: " filename))
       (exit 1)))
    (make-hash-table)))

;; Writes a score-table to a file. This function is the counterpart to
;; 'score-table-read'. It signals an error if the file couldn't be created.
(define (score-table-write score-table filename)
  (define out (open-output-file filename))
  (write-line "; Timestamp of last scoring:" out)
  (write-line
    (number->string (local-time->seconds (seconds->local-time)))
    out)
  (newline out)
  (write-line "; Associative list of strings and their scores:" out)
  (pretty-print
    (score-list-sort
      (hash-table->alist score-table))
    out)
  (close-output-port out))

;; Increases the score of a string in a given score table by 1. An optional
;; third parameter may specify a custom score. This must be a positive
;; floating point value, otherwise this may lead to undefined behaviour.
(define (score-table-learn! score-table str #!optional (score 1.0))
  (define old-score (hash-table-ref/default score-table str 0.0))
  (hash-table-set! score-table str (+ old-score score)))
