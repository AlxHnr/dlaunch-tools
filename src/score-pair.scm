(declare (unit score-pair)
  (export score-pair>?))

(define (score-pair>? a b)
  (define a-score (cdr a))
  (define b-score (cdr b))
  (cond
    ((= a-score b-score)
     (string<? (car a) (car b)))
    ((> a-score b-score) #t)
    (else #f)))
