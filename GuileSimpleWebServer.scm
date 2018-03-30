(add-to-load-path (dirname (current-filename)))

(use-modules (web server)
	     (web request)
	     (web response)
	     (web uri)
	     (ice-9 threads)
	     (ice-9 regex)
	     (ice-9 rdelim)
	     (ice-9 binary-ports)
	     (ice-9 format)
	     (mimety))

(define (request-path request)
  (split-and-decode-uri-path (uri-path (request-uri request))))


(define (request-query-string request)
  (split-and-decode-uri-path (uri-query (request-uri request))))

(define (revove-from-string str regex)
  (if (equal? (string-match regex str) #f)
      str
      (regexp-substitute #f (string-match regex str) 'pre "" 'post)))

(define (code-404 request)
  (values (build-response #:code 404)
	  (string-append
	   (uri->string (request-uri request))
	   "\n"
	   "404 Resource Not Found !\n")))

(define (handle-custom-requests request body)
					; TODO ... remove code duplication for CYGWIN or LINUX
					; in cygwin file name has "http[s]:/" prefix
					; in Parabola Gnu/Linux Libre (hasta la victoria siempre) ;) ... the file name has "/" prefix
					; have to learn and practice more :D
  (let ((file-name-cyqwin (revove-from-string (uri->string (request-uri request)) "http.?:/"))
	(file-name-linux (revove-from-string (uri->string (request-uri request)) "/")))
    
    ;(format #t "\nCygwin file name : ~s " file-name-cyqwin)
    ;(format #t "\nLinux file name  : ~s " file-name-linux)
    (cond
     ((equal? (request-path request) '("hello"))
      (values '((content-type . (text/plain))) "Hello there!"))
     ((equal? (request-path request) '("quit"))
      (values '((content-type . (text/plain))) "Try to quit!"))
     ((file-exists? file-name-linux)
      (let* ((mime-type (mime-type-ref (uri->string (request-uri request))))
	     (mime-type-symbol (mime-type-symbol mime-type)))
	(if (text-mime-type? mime-type)
	    (values
	     `((content-type . (,mime-type-symbol)))
	     (lambda (out-port)
	       (call-with-input-file file-name-linux
		 (lambda (in-port)
		   (display (read-delimited "" in-port)
			    out-port)))))
	    (values
	     `((content-type . (,mime-type-symbol)))
	     (call-with-input-file file-name-linux
	       (lambda (in-port)
		 (get-bytevector-all in-port)))))))
     ((file-exists? file-name-cyqwin)
      (let* ((mime-type (mime-type-ref (uri->string (request-uri request))))
	     (mime-type-symbol (mime-type-symbol mime-type)))
	(if (text-mime-type? mime-type)
	    (values
	     `((content-type . (,mime-type-symbol)))
	     (lambda (out-port)
	       (call-with-input-file file-name-cyqwin
		 (lambda (in-port)
		   (display (read-delimited "" in-port)
			    out-port)))))
	    (values
	     `((content-type . (,mime-type-symbol)))
	     (call-with-input-file file-name-cyqwin
	       (lambda (in-port)
		 (get-bytevector-all in-port)))))))
     (else (code-404 request)))))


(define (custom-handler request body)
  (handle-custom-requests request body))

;;use this with EMACS & Geiser if you want to be able to change the
;;handle-custom-requests procedure and re-eval ... and see the results in the browser (after just a refresh)
;;(define server-thread (make-thread run-server custom-handler))
;;(begin-thread server-thread)   
(run-server custom-handler)
