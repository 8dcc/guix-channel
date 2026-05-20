(define-module (x8dcc-channel build dir-utils)
  #:use-module (ice-9 ftw)
  #:export (first-subdir))

(define (subdir-entry? dir)
  (lambda (f)
    (and (not (member f '("." "..")))
         (file-is-directory?
          (string-append dir "/" f)))))

(define (first-subdir dir)
  (let ((entries (scandir dir (subdir-entry? dir))))
    (and (not (null? entries))
         (string-append dir "/" (car entries)))))
