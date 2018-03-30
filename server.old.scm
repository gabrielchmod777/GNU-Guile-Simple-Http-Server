(add-to-load-path (dirname (current-filename)))

(use-modules (web server)) 
(use-modules (web request)
             (web response)
             (web uri))
(use-modules (ice-9 rdelim))
(use-modules (ice-9 binary-ports))
(use-modules (ice-9 regex))
(use-modules (mimety))
;;;-------------------------------------------------
;;;-------------------------------------------------

(define-public (request-path-components request)
  (split-and-decode-uri-path (uri-path (request-uri request))))


;;;because I have problems with LET :)
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


(define (revove-from-string str regex)
  (regexp-substitute #f (string-match regex str) 'pre "" 'post))


(define (hello-hacker-handler request body)
  (display "\n-------------\n")
  ;;(display (revove-from-string (uri->string (request-uri request)) "http.?:/"))
  ;;;(display (string? (no-first-character (uri->string (request-uri request)))))
  (display "\n+++++++++++++\n")


  (cases request body (revove-from-string (uri->string (request-uri request)) "http.?:/")  )


  )

(define (not-found request)
  (values (build-response #:code 404)
          (string-append "Resource not found: "
                         (uri->string (request-uri request)))))

(run-server hello-hacker-handler)

