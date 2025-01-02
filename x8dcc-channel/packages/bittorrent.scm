(define-module (x8dcc-channel packages bittorrent)
  #:use-module ((x8dcc-channel packages) #:prefix x8dcc-channel:)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build utils)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
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
    (source
     (origin
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
XML-RPC over SCGI.  This version enables support for XMLRPC.")
    (home-page "https://github.com/rakshasa/rtorrent")
    (license license:gpl2+)))

(define-public rtorrent-vi-color
  (package
    (inherit rtorrent-xmlrpc)
    (name "rtorrent-vi-color")
    (version "0.9.8")
    (source
     (origin
      (method url-fetch)
      (uri (string-append
            "https://github.com/rakshasa/rtorrent-archive/raw/master/rtorrent-"
            version ".tar.gz"))
      (sha256
       (base32
        "1bs2fnf4q7mlhkhzp3i1v052v9xn8qa7g845pk9ia8hlpw207pwy"))
      (patches
       (parameterize ((%patch-path x8dcc-channel:%patch-path))
         ;; Credits for the patches:
         ;; https://aur.archlinux.org/packages/rtorrent-vi-color
         ;; https://gitlab.com/lindell.fredrik/rtorrent-vi-color
         (search-patches
          "rtorrent-0.9.8_vi_keybinding.patch"
          "rtorrent-0.9.8_compact_display.patch"
          "rtorrent-0.9.8_color.patch")))))
    (synopsis "BitTorrent client with ncurses interface, color and vi keybinds")
    (description "Variant of `rtorrent-xmlrpc' which adds some patches for:
@itemize
@item Vi-like keybinds
@item Compact display
@item Configurable colors
@end itemize")))
