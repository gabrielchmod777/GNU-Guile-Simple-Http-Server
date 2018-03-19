(use-modules (web server)) 
(use-modules (web request)
             (web response)
             (web uri))
(use-modules (ice-9 rdelim))
(use-modules (ice-9 binary-ports))

;;;-------------------------------------------------
(define *mime-types* (make-hash-table 31))
(hash-set! *mime-types* "css" '("text" . "css"))
(hash-set! *mime-types* "txt" '("text" . "plain"))
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

(define (request-path-components request)
  (split-and-decode-uri-path (uri-path (request-uri request))))
;;;-------------------------------------------------




(define (hello-hacker-handler request body)
  (display "\n-------------\n")
  (display (uri->string (request-uri request)))
  (display "\n+++++++++++++\n")



  (cond ((equal? (request-path-components request) '("hacker"))
	 (values '((content-type . (text/html))) "<h2>Hello hacker!</h2> <img src=\"Apple.png\" alt=\"Smiley face\" height=\"42\" width=\"42\"> "))
	((file-exists? "Apple.png")
	 (display "EXISTS")
              (let* ((mime-type (mime-type-ref (uri->string (request-uri request))))
                     (mime-type-symbol (mime-type-symbol mime-type)))
                (if (text-mime-type? mime-type)
                    (values
                     `((content-type . (,mime-type-symbol)))
                     (lambda (out-port)
                       (call-with-input-file "Apple.png"
                         (lambda (in-port)
                           (display (read-delimited "" in-port)
                                                    out-port)))))
                    (values
                     `((content-type . (,mime-type-symbol)))
                     (call-with-input-file "Apple.png"
                         (lambda (in-port)
                           (get-bytevector-all in-port)))))))
	(else (not-found request))))

(define (not-found request)
  (values (build-response #:code 404)
          (string-append "Resource not found: "
                         (uri->string (request-uri request)))))

(run-server hello-hacker-handler)

