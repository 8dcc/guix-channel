(define-module (x8dcc-channel packages suckless)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build utils)
  #:use-module ((guix licenses) #:prefix licenses:)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages pkg-config))

(define-public dwm
  (package
   (name "dwm")
   (version "6.2.0")
   (synopsis "Dynamic Window Manager for X.")
   (description "DWM is a dynamic window manager for X. It manages windows in
tiled, monocle and floating layouts. All of the layouts can be applied
dynamically, optimising the environment for the application in use and the task
performed.")
   (home-page "https://dwm.suckless.org/")
   (license licenses:x11)
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://github.com/8dcc/linux-dotfiles.git")
           (commit "9808bdb55261ff31f0208f9ae4180d755169bd8d")))
     (sha256 (base32 "1wnqfw8p7irz9jm3ic6v2dpkywwgvn986l9na1y1vfxvqqrll6p0"))))
   (build-system gnu-build-system)
   (arguments
    '(#:phases
      (modify-phases %standard-phases
                     (delete 'configure)
                     (add-after 'unpack 'change-dir
                                (lambda _
                                  (chdir "apps/DWM-6.2/")))
                     (replace 'install
                              (lambda* (#:key outputs #:allow-other-keys)
                                (let ((out (assoc-ref outputs "out")))
                                  (invoke "make"
                                          "install"
                                          (string-append "DESTDIR=" out)
                                          "PREFIX=")))))
      #:tests? #f))
   (inputs (list xorg-server
                 xinit
                 libx11
                 libxft
                 libxinerama
                 freetype
                 pkg-config))))

(define-public st
  (package
   (name "st")
   (version "0.8.2.0")
   (synopsis "8dcc's fork of suckless' simple terminal")
   (description "St implements a simple and lightweight terminal emulator. It
implements 256 colors, most VT10X escape sequences, utf8, X11 copy/paste,
antialiased fonts (using fontconfig), fallback fonts, resizing, and line
drawing.")
   (home-page "https://st.suckless.org/")
   (license (list licenses:x11 licenses:expat))
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://github.com/8dcc/linux-dotfiles.git")
           (commit "50d8d779ef01e03a73c7361b4220e13aebbb92de")))
     (sha256 (base32 "0riw50vc0wq25cn4plfqml12357b9s9lzdwg9qh7vcqhig0j9991"))))
   (build-system gnu-build-system)
   (arguments
    `(#:make-flags
      (list (string-append "CC=" ,(cc-for-target))
            (string-append "TERMINFO="
                           (assoc-ref %outputs "out")
                           "/share/terminfo")
            (string-append "PREFIX=" %output))
      #:phases
      (modify-phases %standard-phases
                     (delete 'configure)
                     (add-after 'unpack 'change-dir
                                (lambda _
                                  (chdir "apps/ST-0.8.2/"))))
      #:tests? #f))
   (inputs (list pkg-config
                 libx11
                 libxft
                 freetype
                 ;; For the `tic' command, used when installing.
                 ncurses))))
