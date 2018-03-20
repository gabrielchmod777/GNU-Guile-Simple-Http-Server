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
(hash-set! *mime-types* "html" '("text" . "html"))
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



(define (cases request body file-name)
  (cond ((equal? (request-path-components request) '("duude"))
	 (values '((content-type . (text/plain))) "Hello duude!"))
	((file-exists? file-name)
	 (display "resource .. ok")
	 (let* ((mime-type (mime-type-ref (uri->string (request-uri request))))
		(mime-type-symbol (mime-type-symbol mime-type)))
	   (if (text-mime-type? mime-type)
	       (values
		`((content-type . (,mime-type-symbol)))
		(lambda (out-port)
		  (call-with-input-file file-name
		    (lambda (in-port)
		      (display (read-delimited "" in-port)
			       out-port)))))
	       (values
		`((content-type . (,mime-type-symbol)))
		(call-with-input-file file-name
		  (lambda (in-port)
		    (get-bytevector-all in-port)))))))
	(else (not-found request)))
  )


(define (no-first-character str)
  (substring str 1 (string-length str)))


(define (hello-hacker-handler request body)
  (display "\n-------------\n")
  (display (no-first-character (uri->string (request-uri request))))
  ;;;(display (string? (no-first-character (uri->string (request-uri request)))))
  (display "\n+++++++++++++\n")


  (cases request body (no-first-character (uri->string (request-uri request)))  )


  )

(define (not-found request)
  (values (build-response #:code 404)
          (string-append "Resource not found: "
                         (uri->string (request-uri request)))))

(run-server hello-hacker-handler)

