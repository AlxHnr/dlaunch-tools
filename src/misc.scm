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

;; This unit contains functions, which are to small for an own unit.

(declare (unit misc)
  (export read-file-or-die))

;; Like 'read-file', but with the difference that it shows an error message
;; to the user and calls (exit 1). It catches only syntax errors, so the
;; file must exist.
(define (read-file-or-die file-path)
  (condition-case
    (read-file file-path)
    ((exn syntax)
     (print-error-message
       (string-append "broken file: " file-path))
     (exit 1))))
