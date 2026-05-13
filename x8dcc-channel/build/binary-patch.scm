(define-module (x8dcc-channel build binary-patch)
  #:use-module (rnrs bytevectors)
  #:use-module (ice-9 binary-ports)
  #:export (patch-bytes
            patch-bytes/mask))

;;; Build-side helpers for in-place byte patching of binaries.  Intended
;;; to be used from package phases via `#:imported-modules' and
;;; `#:modules'.

(define (match-at? bv i pattern mask plen)
  (let loop ((j 0))
    (or (= j plen)
        (and (= (logand (bytevector-u8-ref bv (+ i j))
                        (bytevector-u8-ref mask j))
                (logand (bytevector-u8-ref pattern j)
                        (bytevector-u8-ref mask j)))
             (loop (+ j 1))))))

(define (find-unique bv pattern mask)
  "Return the unique offset in BV where PATTERN matches under MASK.

MASK is a bytevector of the same length as PATTERN; #xFF means `match
exactly', #x00 means `ignore this byte'.

Error if there is not exactly one match."
  (let ((plen (bytevector-length pattern))
        (blen (bytevector-length bv)))
    (let loop ((i 0) (hits '()))
      (cond
       ((> (+ i plen) blen)
        (case (length hits)
          ((1) (car hits))
          ((0) (error "binary-patch: no match"))
          (else (error "binary-patch: multiple matches" hits))))
       ((match-at? bv i pattern mask plen)
        (loop (+ i 1) (cons i hits)))
       (else (loop (+ i 1) hits))))))

(define* (patch-bytes/mask file pattern replacement
                           #:optional
                           (mask (make-bytevector
                                  (bytevector-length pattern) #xFF)))
  "In FILE, find the unique occurrence of PATTERN (under MASK) and
overwrite it with REPLACEMENT.  PATTERN, REPLACEMENT, and MASK must all
have the same length."
  (unless (= (bytevector-length pattern)
             (bytevector-length replacement)
             (bytevector-length mask))
    (error "binary-patch: pattern/replacement/mask length mismatch"))
  (call-with-port (open-file file "r+b")
    (lambda (port)
      (let* ((bv  (get-bytevector-all port))
             (off (find-unique bv pattern mask)))
        (seek port off SEEK_SET)
        (put-bytevector port replacement)))))

(define (patch-bytes file pattern replacement)
  "Exact-match variant of `patch-bytes/mask'."
  (patch-bytes/mask file pattern replacement))
