(define-module (x8dcc-channel packages)
  #:use-module (gnu packages)
  #:export (%patch-path))

(define %patch-path
  (and=> (search-path %load-path "x8dcc-channel/packages.scm")
         (lambda (packages-file)
           (list (string-append (dirname packages-file)
                                "/packages/patches")))))
