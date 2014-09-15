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
  (uses score-pair)
  (export score-table-read
          score-table-write))

(use srfi-69)
(use posix)

(define score-decay-interval (* 60 60 24 2))

;; This function reads an existing score file, as described above, and
;; returns a hash-table which associates a string with its score. It
;; re-scores the a-list using the timestamp specified in the file and
;; signals an error if the file does not exist.
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
    (sort (hash-table->alist score-table) score-pair>?)
    out)
  (close-output-port out))
