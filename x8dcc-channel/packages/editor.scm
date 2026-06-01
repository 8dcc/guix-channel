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
  #:use-module (gnu packages pdf)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages texinfo)
  #:use-module (gnu packages terminals)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages tree-sitter)
  #:use-module (gnu packages web)
  #:use-module (gnu packages xorg)
  #:use-module (x8dcc-channel build dir-utils))

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
       #:imported-modules ((x8dcc-channel build dir-utils)
                           ,@%gnu-build-system-modules)
       #:modules ((x8dcc-channel build dir-utils)
                  (guix build gnu-build-system)
                  (guix build utils))

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
        "CFLAGS=-O2 -pipe")

       #:phases
       (modify-phases %standard-phases
         (add-after 'set-paths 'set-libgccjit-path
           (lambda* (#:key inputs #:allow-other-keys)
             (let* ((libgccjit-libdir
                     (first-subdir
                      (first-subdir
                       (search-input-directory inputs "lib/gcc")))))
               (setenv "LIBRARY_PATH"
                       (string-append (or (getenv "LIBRARY_PATH") "")
                                      ":" libgccjit-libdir)))))

         ;; Hardcode the GCC driver search paths into native-comp-driver-options
         ;; so that libgccjit can find crtbeginS.o and libgcc at runtime when
         ;; JIT-compiling Elisp packages.  substitute* won't work here because
         ;; it operates line-by-line; the defcustom initial value spans two
         ;; lines in Emacs 29.4.
         (add-after 'unpack 'patch-compilation-driver
           (lambda* (#:key inputs #:allow-other-keys)
             (let* ((file "lisp/emacs-lisp/comp.el")
                    (content
                     (call-with-input-file file
                       (lambda (port)
                         (let loop ((acc '()))
                           (let ((c (read-char port)))
                             (if (eof-object? c)
                                 (list->string (reverse acc))
                                 (loop (cons c acc))))))))
                    (options
                     (format #f "'(~@{~s~^ ~})"
                             (string-append
                              "-B" (dirname (search-input-file inputs "/bin/nm")))
                             (string-append
                              "-B" (dirname (search-input-file inputs "/lib/libc.so")))
                             (string-append
                              "-B" (dirname (search-input-file inputs "/lib/libgccjit.so")))
                             (string-append
                              "-B" (string-append
                                    (dirname (search-input-file inputs "/lib/libgccjit.so"))
                                    "/gcc"))))
                    (marker "(defcustom native-comp-driver-options ")
                    (i (string-contains content marker))
                    (j (and i (string-contains content "\n  \"" i))))
               (unless j
                 (error "Could not locate native-comp-driver-options in comp.el"))
               (call-with-output-file file
                 (lambda (port)
                   (display
                    (string-append
                     (substring content 0 (+ i (string-length marker)))
                     options
                     (substring content j))
                    port))))))

         (add-after 'install 'wrap-emacs-binary
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (libvterm-lib
                     (dirname (search-input-file inputs "/lib/libvterm.so"))))
               (wrap-program (string-append out "/bin/emacs")
                 `("LD_LIBRARY_PATH" ":" prefix (,libvterm-lib)))))))))

    (native-inputs
     (list autoconf
           pkg-config
           texinfo))
    (inputs
     (list gnutls
           harfbuzz
           jansson
           libgccjit
           libvterm
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
       ((#:imported-modules _)
        `((x8dcc-channel build dir-utils)
          ,@%glib-or-gtk-build-system-modules))
       ((#:modules _)
        '((x8dcc-channel build dir-utils)
          (guix build glib-or-gtk-build-system)
          (guix build utils)))
       ((#:configure-flags flags)
        `(append (list "--with-x-toolkit=gtk3"
                       "--with-cairo")
                 ,flags))
       ((#:phases phases)
        `(modify-phases ,phases

         ;; glib-or-gtk-wrap treats the pdmp as an executable and replaces
         ;; it with a shell script; rename it back so Emacs can load it.
         (add-after 'glib-or-gtk-wrap 'restore-emacs-pdmp
             (lambda* (#:key outputs #:allow-other-keys)
               (let* ((libexec (string-append (assoc-ref outputs "out")
                                              "/libexec"))
                      (pdmp (find-files libexec "\\.pdmp$"))
                      (pdmp-real (find-files libexec "\\.pdmp-real$")))
                 (for-each rename-file pdmp-real pdmp))))))))

    (inputs
     (modify-inputs (package-inputs emacs-29.4)
       (prepend cairo
                dbus
                giflib
                gtk+
                libotf
                libpng
                (librsvg-for-system)
                libjpeg-turbo
                libtiff
                libwebp
                libx11
                libxft
                libxpm
                pango
                poppler)))))
