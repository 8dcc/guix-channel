(define-module (x8dcc-channel packages bittorrent)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build utils)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bittorrent)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages cyrus-sasl)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages check)
  #:use-module (gnu packages pkg-config))

(define-public rtorrent-xmlrpc
  (package
    (name "rtorrent-xmlrpc")
    (version "0.9.8")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/rakshasa/rtorrent-archive/raw/master/rtorrent-"
                    version ".tar.gz"))
              (sha256
               (base32
                "1bs2fnf4q7mlhkhzp3i1v052v9xn8qa7g845pk9ia8hlpw207pwy"))))
    (build-system gnu-build-system)
    (arguments '(#:configure-flags '("--with-xmlrpc-c=yes")))
    (inputs (list libtorrent
                  ncurses
                  curl
                  cyrus-sasl
                  openssl
                  zlib
                  xmlrpc-c))
    (native-inputs (list pkg-config cppunit))
    (synopsis "BitTorrent client with ncurses interface (XMLRPC build)")
    (description
     "rTorrent is a BitTorrent client with an ncurses interface.  It supports
full encryption, DHT, PEX, and Magnet Links.  It can also be controlled via
XML-RPC over SCGI.")
    (home-page "https://github.com/rakshasa/rtorrent")
    (license license:gpl2+)))

rtorrent-xmlrpc
