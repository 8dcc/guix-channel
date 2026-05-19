(define-module (x8dcc-channel packages editor)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system glib-or-gtk)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages image)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages texinfo)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages tree-sitter)
  #:use-module (gnu packages web)
  #:use-module (gnu packages xorg))

(define-public emacs-29.4
  (package
    (name "emacs-29.4")
    (version "29.4")
    (synopsis "The extensible, customizable, self-documenting text editor")
    (description "GNU Emacs is an extensible and highly customizable text
editor based on an Emacs Lisp interpreter with extensions for text editing.
This base package carries the configure flags and inputs that are common to
every variant; the actual display backend is chosen by the children.")
    (home-page "https://www.gnu.org/software/emacs/")
    (license license:gpl3+)
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://gnu/emacs/emacs-" version ".tar.xz"))
       (sha256
        (base32 "0dd2mh6maa7dc5f49qdzj7bi4hda4wfm1cvvgq560djcz537k2ds"))
       (patches
        (list (local-file "patches/emacs-29.4-terminfo-tab-width.patch")))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f
       #:configure-flags
       (list
        ;; Strip host/build date from the version string. Helps with
        ;; reproducible builds; no functional impact.
        "--disable-build-details"

        ;; Ahead-of-time native compilation of all Elisp (gccemacs).
        ;; Big startup and runtime speedup, at the cost of build time.
        "--with-native-compilation=aot"

        ;; Built-in tree-sitter support (major-mode performance).
        "--with-tree-sitter"

        ;; Dynamic modules (vterm, etc.).
        "--with-modules"

        ;; HarfBuzz text shaping (faster, better-looking).
        "--with-harfbuzz"

        ;; Skip compression of installed .el files: faster startup at
        ;; the cost of a bigger store item.
        "--without-compress-install"

        ;; Optimization flags. Note that '-march=native' breaks reproducibility,
        ;; so it is left commented out.
        "CFLAGS=-O2 -pipe"
        )))
    (native-inputs
     (list autoconf
           pkg-config
           texinfo))
    (inputs
     (list gnutls
           harfbuzz
           jansson
           libgccjit
           ncurses
           tree-sitter
           zlib))))

(define-public emacs-cli
  (package
    (inherit emacs-29.4)
    (name "emacs-cli")
    (synopsis "GNU Emacs, console-only build (no X, no sound)")
    (description "Console-only Emacs build, equivalent to Arch's
@code{emacs-nox}.  Drops the X/GTK toolchain in favour of a smaller closure
suitable for headless machines and TTY use.")
    (arguments
     (substitute-keyword-arguments (package-arguments emacs-29.4)
       ((#:configure-flags flags)
        `(append (list "--without-x"
                       "--without-sound")
                 ,flags))))))

(define-public emacs-gui
  (package
    (inherit emacs-29.4)
    (name "emacs-gui")
    (synopsis "GNU Emacs with X11 + GTK 3 support")
    (description "Full GUI Emacs build with X11 and GTK 3.  This is the
closest analogue to Arch's main @code{emacs} package.")
    (build-system glib-or-gtk-build-system)
    (arguments
     (substitute-keyword-arguments (package-arguments emacs-29.4)
       ((#:configure-flags flags)
        `(append (list "--with-x-toolkit=gtk3"
                       "--with-cairo")
                 ,flags))))
    (inputs
     (modify-inputs (package-inputs emacs-29.4)
       (prepend cairo
                gtk+
                libpng
                (librsvg-for-system)
                libjpeg-turbo
                libtiff
                libx11
                libxft
                libxpm
                pango)))))
