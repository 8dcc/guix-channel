(define-module (x8dcc-channel packages self)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build utils)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages pkg-config))

(define-public snc
  (package
    (name "snc")
    (version "1.0.0")
    (synopsis "Simple netcat(1) alternative")
    (description "Simple netcat(1) alternative in C using sockets.")
    (home-page "https://github.com/8dcc/snc")
    (license license:gpl3+)
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/8dcc/snc.git")
             (commit "v1.0.0")))
       (sha256
        (base32 "1zdf0y2miyydmnj2c17ph3hhysii2nns88399z043cnzjds8py8n"))))
    (build-system gnu-build-system)
    (arguments
     `(#:make-flags
       (list (string-append "CC=" ,(cc-for-target))
             (string-append "PREFIX=" %output))
       #:phases
       (modify-phases %standard-phases
         (delete 'configure))
       #:tests? #f))))

(define-public plumber
  (package
    (name "plumber")
    (version "1.0.0")
    (synopsis "Simple alternative to Plan9's plumber.")
    (description "Run different commands depending on the text format.")
    (home-page "https://github.com/8dcc/plumber")
    (license license:gpl3+)
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/8dcc/plumber.git")
             (commit "v1.0.0")))
       (sha256
        (base32 "17x0v8lknnjzjnjrh0kw7pinfw2i6c3b1hv8a0xmvl4p0v6ms44s"))))
    (build-system gnu-build-system)
    (arguments
     `(#:make-flags
       (list (string-append "CC=" ,(cc-for-target))
             (string-append "PREFIX=" %output))
       #:phases
       (modify-phases %standard-phases
         (delete 'configure))
       #:tests? #f))))
