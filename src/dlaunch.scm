;; A wrapper around dmenu, which honors special arguments defined in
;; 'dmenu-args.scm'.
(use posix)
(declare (uses dmenu-wrapper))
(process-execute "dmenu" (append dmenu-args (command-line-arguments)))
