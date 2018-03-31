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


					; linux case is tested
					; Unix , Cygwin and others .. are 'Hail Mary' cases :D
(define (get-file-name request)
  (cond ((not (equal? (string-match "[Ll][Ii][Nn][Uu][Xx]" (utsname:sysname (uname))) #f))
	 (revove-from-string (uri->string (request-uri request)) "/"))
	((not (equal? (string-match "[Uu][Nn][Ii][Xx]" (utsname:sysname (uname))) #f))
	 (revove-from-string (uri->string (request-uri request)) "/"))
	((not (equal? (string-match "[Cc][Yy][Gg][Ww][Ii][Nn]" (utsname:sysname (uname))) #f))
	 (revove-from-string (uri->string (request-uri request)) "http.?:/"))
	(else (uri->string (request-uri request)))))
	 
(define (handle-custom-requests request body)
  (let ((file-name (get-file-name request)))

					; keep printline debuging for a while
    (display "\nDBG -> If file name has any prefix ['/', 'http:.*', etc ] ... there is a problem in function (get-file-name)")
    (format #t "\nFile name  : ~s " file-name)
    
    (cond
     ((equal? (request-path request) '("hello"))
      (values '((content-type . (text/plain))) "Hello there!"))
     ((equal? (request-path request) '("quit"))
      (values '((content-type . (text/plain))) "Try to quit!"))
     ((file-exists? file-name)
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
     (else (code-404 request)))))


(define (custom-handler request body)
  (handle-custom-requests request body))

;;use this with EMACS & Geiser if you want to be able to change the
;;handle-custom-requests procedure and re-eval ... and see the results in the browser (after just a refresh)
;;(define server-thread (make-thread run-server custom-handler))
;;(begin-thread server-thread)   
(run-server custom-handler)
