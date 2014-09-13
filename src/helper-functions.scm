(declare (unit helper-functions)
  (export fold-lines-in-file))

(use extras)

;; Folds 'fun' over each line in 'file-path'. 'fun' must be a function,
;; which takes a string as the first argument, and its previous returned
;; value as the second. On the first call 'seed' is passed to 'fun'.
(define (fold-lines-in-file fun seed file-path)
  (define in (open-input-file file-path))
  (define (read-loop obj)
    (define line (read-line in))
    (if (eof-object? line)
      (begin
        (close-input-port in)
        obj)
      (read-loop (fun line obj))))
  (read-loop seed))
