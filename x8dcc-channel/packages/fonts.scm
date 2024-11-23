(define-module (x8dcc-channel packages fonts)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix download)
  #:use-module (guix build-system font)
  #:use-module (guix build utils)
  #:use-module ((guix licenses) #:prefix license:))

(define-public font-dina
  (package
    (name "font-dina")
    (version "2.92")
    (source (origin
              (method url-fetch/zipbomb)
              (uri "https://www.dcmembers.com/jibsen/download/61/?wpdmdl=61")
              (file-name "Dina.zip")
              (sha256
               (base32
                "1kq86lbxxgik82aywwhawmj80vsbz3hfhdyhicnlv9km7yjvnl8z"))))
    (build-system font-build-system)
    (home-page "https://www.dcmembers.com/jibsen/download/61/")
    (synopsis "Dina programming font")
    (description "Dina is a monospace bitmap font, primarily aimed at
programmers. It is relatively compact to allow a lot of code on screen, while
(hopefully) clear enough to remain readable even at high resolutions.")
    (license license:expat)))
