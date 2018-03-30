(add-to-load-path (dirname (current-filename)))

(use-modules (web server)
	     (web request)
	     (web response)
	     (web uri)
	     (ice-9 threads))

(define (request-path request)
  (split-and-decode-uri-path (uri-path (request-uri request))))


(define (request-query-string request)
  (split-and-decode-uri-path (uri-query (request-uri request))))


(define (code-404 request)
  (values (build-response #:code 404)
	  (string-append
	   (uri->string (request-uri request))
	   "\n"
	   "404 Resource Not Found !\n")))

(define (handle-custom-requests request body)
  (cond
   ((equal? (request-path request) '("hello"))
    (values '((content-type . (text/plain))) "Hello there!"))
   ((equal? (request-path request) '("quit"))
    (values '((content-type . (text/plain))) "Try to quit!"))
   (else (code-404 request))))


(define (custom-handler request body)
  (handle-custom-requests request body))

;;(define server-thread (make-thread run-server custom-handler))
;;(begin-thread server-thread)   
(run-server custom-handler)
