(define-module (query_parser)
  #:export (get-query-as-hashtable))
(use-modules (ice-9 regex))

(define (get-query-as-hashtable query)

  (define (split-kv-pairs str)
    (map match:substring (list-matches "[^=]*" str)))
  (define first car)
  (define second cadr)
  
  (let ((q-table (make-hash-table 31))
	(pairs (map match:substring (list-matches "[^&]*" query))))
    (map (lambda (query-kv-str)
	   (let ((tmp-kv (split-kv-pairs query-kv-str)))
	     (hash-set! q-table (first tmp-kv) (second tmp-kv)))) pairs)
    q-table))


