(define-module (x8dcc-channel packages self)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build utils)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages image)
  #:use-module (gnu packages pkg-config))

(define-public snc
  (package
    (name "snc")
    (version "1.1.1")
    (synopsis "Simple netcat(1) alternative")
    (description "Simple netcat(1) alternative in C using sockets.")
    (home-page "https://github.com/8dcc/snc")
    (license license:gpl3+)
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/8dcc/snc")
             (commit (string-append "v" version))))
       (sha256
        (base32 "15n69bsvbiklm3wiyy2kdfzclh34ygjc9ivn4cvnczllw435cfy6"))))
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
    (synopsis "Simple alternative to Plan9's plumber")
    (description "Run different commands depending on the text format.")
    (home-page "https://github.com/8dcc/plumber")
    (license license:gpl3+)
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/8dcc/plumber")
             (commit (string-append "v" version))))
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

(define-public bin-graph
  (package
    (name "bin-graph")
    (version "1.0.0")
    (synopsis "Visualize binary files")
    (description "This program provides a simple way of visualizing the
different regions of a binary file.")
    (home-page "https://github.com/8dcc/bin-graph")
    (license license:gpl3+)
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/8dcc/bin-graph")
             (commit "45b89b862e1ec445eb099cefecceaaae83840ba2")))
       (sha256
        (base32 "16hwj4pr0yppgfaa0hybcknwg63x8bbg2shknk6dknvvhqccddpd"))))
    (build-system gnu-build-system)
    (arguments
     `(#:make-flags
       (list (string-append "CC=" ,(cc-for-target))
             (string-append "PREFIX=" %output))
       #:phases
       (modify-phases %standard-phases
         (delete 'configure))
       #:tests? #f))
    (inputs (list libpng
                  ;; For 'bin-graph-section.sh'.
                  grep))))
