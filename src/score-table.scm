;; This unit provides an interface between a score-file and a score-table.
;; This unit also handles the re-scoring and decay of scores. Such a score
;; file has a very simple structure: it is a simple scheme file containing
;; a floating point value followed by an arbitrary amount of pairs. The
;; floating point value represents the time in seconds of the last scoring.
;; The pairs associate a string with its score. Before the pairs are
;; converted into a hash-table, they will be re-scored.
(declare (unit score-table)
  (export score-table-read))

(use srfi-69)
(use posix)

(define score-decay-interval (* 60 60 24 2))

;; This function reads a score-table from a given file and returns a
;; hash-table which associates the scored string with its new score. It
;; re-scores the table using the time stamp of the file and throws a file
;; exception if the file does not exist.
(define (score-table-read filename)
  (define score-file-content (read-file filename))
  (define score-list (cdr score-file-content))
  ; The time difference between the current-time and the last time the file
  ; was scored.
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
