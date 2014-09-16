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

;; This unit allows a list of strings to be sorted by using a
;; 'score-table'. A score-list is just an associative list assigning a
;; string to its score.

(declare (unit score-list)
  (uses score-table)
  (export score-list-add
          score-list-sort
          score-list-harvest))

(use srfi-69)

;; Creates a new list from 'lst' containing the added string. This function
;; relies on informations provided by a score-table. It is possible to add
;; the same string multiple times.
(define (score-list-add lst str score-table)
  (cons
    (cons str (hash-table-ref/default score-table str 0))
    lst))

;; Sorts a score list and returns it.
(define (score-list-sort lst)
  (sort lst (lambda (a b)
              (if (= (cdr a) (cdr b))
                (string<? (car a) (car b))
                (> (cdr a) (cdr b))))))

;; Returns a list of strings sorted by their score. Takes a valid
;; score-list.
(define (score-list-harvest lst)
  (map car (score-list-sort lst)))
