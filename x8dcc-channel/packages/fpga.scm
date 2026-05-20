(define-module (x8dcc-channel packages fpga)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix download)
  #:use-module (guix build-system copy)
  #:use-module (guix build utils)
  #:use-module (x8dcc-channel build binary-patch)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bootstrap)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages crypto)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages kerberos)
  #:use-module (gnu packages libusb)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages xdisorg))

(define-public gowin-eda
  (package
    (name "gowin-eda")
    (version "1.9.12.02")
    (source
     (origin
      (method url-fetch)
      (uri (string-append
            "http://cdn.gowinsemi.com.cn/Gowin_V" version "_linux.tar.gz"))
      (sha256
       (base32
        "1748lmggl9y9qkgknsd8941rn526yz10k0kgp02yvskl57mp4r0v"))))
    (build-system copy-build-system)
    (arguments
     `(#:modules ((x8dcc-channel build binary-patch)
                  (guix build copy-build-system)
                  (guix build utils))
       #:imported-modules ((x8dcc-channel build binary-patch)
                           ,@%copy-build-system-modules)
       #:install-plan
       '(("IDE"        "share/gowin-eda/IDE")
         ("Programmer" "share/gowin-eda/Programmer"))
       #:phases
       (modify-phases %standard-phases
         ;; The tarball has `IDE' and `Programmer' as sibling top-level
         ;; directories.  The default `unpack' phase chdirs into the first
         ;; subdirectory it finds (`IDE'), so step back to see both.
         (add-after 'unpack 'chdir-to-root
           (lambda _
             (chdir "..")))

         ;; Documentation directories are large and not needed at runtime.
         (add-after 'chdir-to-root 'drop-doc
           (lambda _
             (for-each delete-file-recursively
                       '("IDE/doc" "Programmer/doc"))))

         ;; Patch the license verification code in `gw_ide'.
         (add-after 'install 'patch-gw-ide
           (lambda* (#:key outputs #:allow-other-keys)
             (patch-bytes/mask
              (string-append (assoc-ref outputs "out")
                             "/share/gowin-eda/IDE/bin/gw_ide")
              #vu8(#x85 #xC0               ; test eax, eax
                   #x75 #x31               ; jne  0x405465
                   #x8B #x7C #x24 #x1C     ; mov  edi, dword [rsp + 0x1c]
                   #x4C #x89 #xF6          ; mov  rsi, r14
                   #xE8)                   ; call ...
              #vu8(#x85 #xC0
                   #x74 #x31               ; Replace opcode 75 (JNE) -> 74 (JE)
                   #x8B #x7C #x24 #x1C
                   #x4C #x89 #xF6
                   #xE8)
              #vu8(#xFF #xFF
                   #xFF #x00               ; Jump destination may vary
                   #xFF #xFF #xFF #x00     ; Stack offset may vary
                   #xFF #xFF #xFF
                   #xFF))))

         ;; The bundled libfreetype.so.6 conflicts with the system
         ;; fontconfig and breaks IDE startup. See:
         ;; https://bbs.archlinux.org/viewtopic.php?id=251445
         (add-after 'install 'drop-bundled-libs
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((libdir (string-append (assoc-ref outputs "out")
                                          "/share/gowin-eda/IDE/lib")))
               (for-each (lambda (name)
                           (let ((f (string-append libdir "/" name)))
                             (when (file-exists? f)
                               (delete-file f))))
                         '("libfreetype.so.6"
                           "libstdc++.so.6")))))

         (add-after 'drop-bundled-libs 'patchelf-binaries
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (let* ((out  (assoc-ref outputs "out"))
                    (ld   (string-append (assoc-ref inputs "glibc")
                                         ,(glibc-dynamic-linker)))
                    (ide  (string-append out "/share/gowin-eda/IDE"))
                    (prog (string-append out "/share/gowin-eda/Programmer"))
                    (store-rpath
                     (string-join
                      (map (lambda (entry)
                             (let ((label  (car entry))
                                   (subdir (cdr entry)))
                               (string-append (assoc-ref inputs label)
                                              "/lib" subdir)))
                           ;; (LABEL . EXTRA-SUBDIR-UNDER-/lib).  Guix's
                           ;; `nss' installs its shared libraries under
                           ;; `lib/nss', not directly in `lib'.
                           '(("glibc"        . "")
                             ("gcc:lib"      . "")
                             ("fontconfig"   . "")
                             ("freetype"     . "")
                             ("zlib"         . "")
                             ("libx11"       . "")
                             ("libxext"      . "")
                             ("libxrender"   . "")
                             ("libxcb"       . "")
                             ("libxkbcommon" . "")
                             ("mesa"         . "")
                             ("dbus"         . "")
                             ("glib"         . "")
                             ("libusb"       . "")
                             ("eudev"        . "")
                             ("nss"          . "")
                             ("nss"          . "/nss")
                             ("nspr"         . "")
                             ("libxcomposite" . "")
                             ("libxdamage"   . "")
                             ("libxfixes"    . "")
                             ("libxrandr"    . "")
                             ("libxtst"      . "")
                             ("expat"        . "")
                             ("alsa-lib"     . "")
                             ("mit-krb5"     . "")
                             ("keyutils"     . "")
                             ("xcb-util"     . "")))
                      ":"))
                    (patch-dir
                     (lambda (dir extra-rpaths)
                       (for-each
                        (lambda (f)
                          (when (and (not (symbolic-link? f))
                                     (elf-file? f))
                            (false-if-exception
                             (invoke "patchelf" "--set-interpreter" ld f))
                            (false-if-exception
                             (invoke "patchelf" "--set-rpath"
                                     (string-join
                                      (cons store-rpath extra-rpaths) ":")
                                     f))))
                        (find-files dir)))))
               (patch-dir (string-append ide "/bin")
                          (list (string-append ide "/lib")))
               (patch-dir (string-append ide "/lib")
                          (list (string-append ide "/lib")))
               (patch-dir (string-append ide "/plugins")
                          (list (string-append ide "/lib")))
               (patch-dir (string-append prog "/bin")
                          (list (string-append prog "/bin"))))))

         (add-after 'patchelf-binaries 'install-wrappers
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out  (assoc-ref outputs "out"))
                    (bin  (string-append out "/bin"))
                    (ide  (string-append out "/share/gowin-eda/IDE"))
                    (prog (string-append out "/share/gowin-eda/Programmer"))
                    (write-wrapper
                     (lambda (path contents)
                       (call-with-output-file path
                         (lambda (port) (display contents port)))
                       (chmod path #o755))))
               (mkdir-p bin)
               (write-wrapper (string-append bin "/gw_ide")
                              (string-append
                               "#!/bin/sh\n"
                               "export LD_LIBRARY_PATH=" ide "/lib\n"
                               "exec " ide "/bin/gw_ide \"$@\"\n"))
               (write-wrapper (string-append bin "/gw_sh")
                              (string-append
                               "#!/bin/sh\n"
                               "export LD_LIBRARY_PATH=" ide "/lib\n"
                               "exec " ide "/bin/gw_sh \"$@\"\n"))
               (write-wrapper (string-append bin "/gowin-programmer")
                              (string-append
                               "#!/bin/sh\n"
                               "exec " prog "/bin/programmer \"$@\"\n"))
               (write-wrapper (string-append bin "/gowin-programmer-cli")
                              (string-append
                               "#!/bin/sh\n"
                               "exec " prog "/bin/programmer_cli \"$@\"\n"))))))))

    (inputs
     `(("glibc"         ,glibc)
       ("gcc:lib"       ,gcc "lib")
       ("fontconfig"    ,fontconfig)
       ("freetype"      ,freetype)
       ("zlib"          ,zlib)
       ("libx11"        ,libx11)
       ("libxext"       ,libxext)
       ("libxrender"    ,libxrender)
       ("libxcb"        ,libxcb)
       ("libxkbcommon"  ,libxkbcommon)
       ("mesa"          ,mesa)
       ("dbus"          ,dbus)
       ("glib"          ,glib)
       ("libusb"        ,libusb)
       ("eudev"         ,eudev)
       ("nss"           ,nss)
       ("nspr"          ,nspr)
       ("libxcomposite" ,libxcomposite)
       ("libxdamage"    ,libxdamage)
       ("libxfixes"     ,libxfixes)
       ("libxrandr"     ,libxrandr)
       ("libxtst"       ,libxtst)
       ("expat"         ,expat)
       ("alsa-lib"      ,alsa-lib)
       ("mit-krb5"      ,mit-krb5)
       ("keyutils"      ,keyutils)
       ("xcb-util"      ,xcb-util)))
    (native-inputs (list patchelf))
    (supported-systems '("x86_64-linux"))
    (synopsis "Integrated design environment for Gowin FPGAs")
    (description "Gowin EDA is the proprietary integrated design environment
for Gowin FPGAs.  It provides:
@itemize
@item Design entry and project management
@item Synthesis, place-and-route, and timing analysis
@item Simulation and on-chip debugging (GAO, GVIO)
@item Device programming via the bundled Gowin Programmer
@end itemize
This package bundles the upstream Linux binary release, patched to run under
Guix using @code{patchelf}.")
    (home-page "https://www.gowinsemi.com.cn/software/index")
    (license #f)))
