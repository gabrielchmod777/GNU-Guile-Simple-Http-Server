(define-module (mimety)
  #:export (mime-type-ref mime-type-symbol text-mime-type?))

(define *mime-types* (make-hash-table 31))
(hash-set! *mime-types* "css" '("text" . "css"))
(hash-set! *mime-types* "txt" '("text" . "plain"))
(hash-set! *mime-types* "html" '("text" . "html"))
(hash-set! *mime-types* "js" '("text" . "javascript"))
(hash-set! *mime-types* "png" '("image" . "png"))
(hash-set! *mime-types* "jpg" '("image" . "jpeg"))
(hash-set! *mime-types* "jpeg" '("image" . "jpeg"))
(hash-set! *mime-types* "gif" '("image" . "gif"))

(define (mime-type-ref file-name)
  (let* ((dot-position (string-rindex file-name #\.))
         (extension (and dot-position
                         (string-copy file-name (+ dot-position 1))))
         (mime-type (and dot-position
                         (hash-ref *mime-types* extension))))
    (if mime-type mime-type '("application" . "octet-stream"))))

(define (mime-type-symbol mime-type)
  (string->symbol (string-append (car mime-type) "/" (cdr mime-type))))

(define (text-mime-type? mime-type)
  (if (equal? (car mime-type) "text") #t #f))

