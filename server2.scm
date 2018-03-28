
;;; TODO --- study this --- http://guile-user.gnu.narkive.com/HYHCwBLY/the-web-continuations-and-all-that

;;; finally we have the query


(use-modules (web server)) ; you probably did this already
(use-modules (web request)
             (web response)
             (web uri))



(define dispatch-table (make-hash-table))

(define (handler request body)
  (let* ((query (split-and-decode-uri-path (uri-query (request-uri request))))
	 (path (split-and-decode-uri-path (uri-path (request-uri request))))
	 (h (hash-ref dispatch-table (string->symbol (car path)))))
    (if h
	(% (h request body))
	(begin
	  (display "\n=p=\n")
	  (display path)
	  (display "\n=q=\n")
	  (display query)
	(values '((content-type . (text/plain)))
		(string-append "Unknown page: " (car path)))
	    ))))
  

(define (request-path-components request)
  (split-and-decode-uri-path (uri-path (request-uri request))))

(define (hello-hacker-handler request body)
  (if (equal? (request-path-components request)
              '("hacker"))
      (values '((content-type . (text/plain)))
              "Hello hacker!")
      (not-found request)))

(run-server handler)
