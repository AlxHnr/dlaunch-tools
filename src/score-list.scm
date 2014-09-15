;; This unit allows a list of strings to be sorted by using a
;; 'score-table'. A score-list is just an associative list assigning a
;; string to its score.
(declare (unit score-list)
  (uses score-table score-pair)
  (export score-list-add
          score-list-harvest))

(use srfi-69)

;; Creates a new list from 'lst' containing the added string. This function
;; relies on informations provided by a score-table. It is possible to add
;; the same string multiple times.
(define (score-list-add lst str score-table)
  (cons
    (cons str (hash-table-ref/default score-table str 0))
    lst))

;; Returns a list of strings sorted by their score. Takes a valid
;; score-list.
(define (score-list-harvest lst)
  (map car (sort lst score-pair>?)))
