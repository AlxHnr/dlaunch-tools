(declare (uses score-list))
(use test extras srfi-1 srfi-69)

;; A list containing various score lists sorted in the expected order.
(define sorted-score-lists
  '((("Foo"    . 123.0)
     ("Gentoo" . 99.99)
     ("Linux"  . 50)
     ("Abc"    . 0.0)
     ("Bar"    . 0.0))
    (("GitHub"    . 45.30)
     ("Vim"       . 40.0)
     ("Scripting" . 12.0)
     ("Bash"      . 0.0))
    (("Alpha" . 10.0)
     ("Beta"  . 10.0)
     ("Gamma" . 10.0)
     ("alpha" . 10.0)
     ("beta"  . 10.0)
     ("gamma" . 10.0))))

(define harvested-score-lists
  (map
    (lambda (lst)
      (map car lst))
    sorted-score-lists))

(define (shuffle-list lst)
  (sort
    lst
    (lambda (a b)
      (< (random 32768) 16384))))

;; Maps thunk over sorted-score-lists and compares to result.
(define (test-sort-function thunk result)
  (test
    "Manually inserting score pairs" result
    (map thunk (map shuffle-list sorted-score-lists)))
  (test
    "Inserting with 'score-list-add'" result
    (map
      (lambda (score-list)
        (define table
          (alist->hash-table (shuffle-list score-list)))
        (thunk
          (fold
            (lambda (str lst)
              (score-list-add lst str table))
            '() (map car (shuffle-list score-list)))))
      (map shuffle-list sorted-score-lists))))

(test-begin "score-list")

(test-group
  "score-list-sort"
  (test-sort-function
    score-list-sort
    sorted-score-lists))

(test-group
  "score-list-harvest"
  (test-sort-function
    score-list-harvest
    harvested-score-lists))

(test-end)
(test-exit)
