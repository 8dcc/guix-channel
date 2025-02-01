(define-module (x8dcc-channel packages suckless)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build utils)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages crypto)
  #:use-module (gnu packages pkg-config))

(define-public dwm
  (package
    (name "dwm")
    (version "6.2.0")
    (synopsis "8dcc's fork of suckless' dynamic window manager")
    (description "DWM is a dynamic window manager for X.  It manages windows in
tiled, monocle and floating layouts.  All of the layouts can be applied
dynamically, optimising the environment for the application in use and the task
performed.")
    (home-page "https://dwm.suckless.org/")
    (license license:x11)
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/8dcc/linux-dotfiles")
             (commit "0047d2a97dec7d6bd65a1c650b830754b1ab99f1")))
       (sha256
        (base32 "1nf2simy5408c8k2xk7cg1hh0z37fgzqa67sqppc65h0cknh1y0i"))))
    (build-system gnu-build-system)
    (arguments
     `(#:make-flags
       (list (string-append "CC=" ,(cc-for-target))
             (string-append "PREFIX=" %output))
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (add-after 'unpack 'change-dir
           (lambda _
             (chdir "apps/DWM-6.2/"))))
       #:tests? #f))
    (native-inputs
     (list pkg-config))
    (inputs
     (list xorg-server
           xinit
           libx11
           libxft
           libxinerama
           freetype))))

(define-public st
  (package
    (name "st")
    (version "0.8.2.0")
    (synopsis "8dcc's fork of suckless' simple terminal")
    (description "St implements a simple and lightweight terminal emulator.  It
implements 256 colors, most VT10X escape sequences, utf8, X11 copy/paste,
antialiased fonts (using fontconfig), fallback fonts, resizing, and line
drawing.")
    (home-page "https://st.suckless.org/")
    (license (list license:x11 license:expat))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/8dcc/linux-dotfiles")
             (commit "50d8d779ef01e03a73c7361b4220e13aebbb92de")))
       (sha256
        (base32 "0riw50vc0wq25cn4plfqml12357b9s9lzdwg9qh7vcqhig0j9991"))))
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
    (native-inputs
     (list pkg-config))
    (inputs
     (list libx11
           libxft
           freetype
           ;; For the `tic' command, used when installing.
           ncurses))))

(define-public dmenu
  (package
    (name "dmenu")
    (version "5.0.0")
    (synopsis "8dcc's fork of suckless' dmenu")
    (description "A dynamic menu for X, originally designed for dwm.  It manages
large numbers of user-defined menu items efficiently.")
    (home-page "https://tools.suckless.org/dmenu/")
    (license (list license:x11))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/8dcc/linux-dotfiles")
             (commit "5eecfda6bf0facc8219ba65814ca77797b59d86f")))
       (sha256
        (base32 "17s0ar8x9zfsgdiflmj37s6wpx53jc8fa1pfjg1a2df1q9pd5dpp"))))
    (build-system gnu-build-system)
    (arguments
     `(#:make-flags
       (list (string-append "CC=" ,(cc-for-target))
             (string-append "PREFIX=" %output))
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (add-after 'unpack 'change-dir
           (lambda _
             (chdir "apps/DMENU/"))))
       #:tests? #f))
    (native-inputs
     (list pkg-config))
    (inputs
     (list libx11
           libxft
           libxinerama))))

(define-public slock
  (package
    (name "slock")
    (version "1.4.0")
    (synopsis "8dcc's fork of suckless' slock")
    (description
     "Simple X session lock with trivial feedback on password entry.")
    (home-page "https://tools.suckless.org/slock/")
    (license (list license:x11))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/8dcc/linux-dotfiles")
             (commit "db3bb33a086b18840440b6f3bfb3838bfc456ca6")))
       (sha256
        (base32 "17x4181lchxqjcn722gmz7y818wx2y4vn437zkcn9pcs5048bc0d"))))
    (build-system gnu-build-system)
    (arguments
     `(#:make-flags
       (list (string-append "CC=" ,(cc-for-target))
             (string-append "PREFIX=" %output)
             "CREATEUSER=no")
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (add-after 'unpack 'change-dir
           (lambda _
             (chdir "apps/SLOCK/"))))
       #:tests? #f))
    (native-inputs
     (list pkg-config))
    (inputs
     (list libx11
           libxft
           libxrandr
           libxinerama
           libxcrypt))))
