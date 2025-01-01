(define-module (x8dcc-channel packages)
  #:use-module (gnu packages)
  #:export (%patch-path))

(define %patch-path
  (let ((packages-file (search-path %load-path "x8dcc-channel/packages.scm")))
    (and packages-file
         (list (string-append (dirname packages-file)
                              "/packages/patches")))))
