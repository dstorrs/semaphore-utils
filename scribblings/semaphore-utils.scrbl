#lang scribble/manual

@(require (for-label racket)
          racket/sandbox
          scribble/example)

@title{semaphore-utils}
@author{David K. Storrs}

@defmodule[semaphore-utils]

A small library for working with semaphores. 


@defproc[(call/sema [sema (or/c #f semaphore?)]
                    [thnk (-> any)]) any]{If @racketid[sema] is @racket[#f], call @racketid[thnk] with no arguments.  If @racketid[sema] is a @racket[semaphore?], call @racketid[thnk] with no arguments inside a @racket[call-with-semaphore].

                                             This is useful when you two functions that share a semaphore and one of them needs to call the other -- it lets you tell the inner one not to use the semaphore since the outer one is already doing so.} 

@(define eval
   (call-with-trusted-sandbox-configuration
    (lambda ()
      (parameterize ([sandbox-output 'string]
                     [sandbox-error-output 'string]
                     [sandbox-memory-limit 50])
        (make-evaluator 'racket)))))

@examples[
 #:eval eval
 #:label #f
 (code:comment "Note:  The following code is intended for simplicity of example.  In real use it would be")
 (code:comment "better to, e.g., not share mutable state between threads and, at a minimum, to expose")
 (code:comment "separate versions of the get-* functions that do not allow passing a semaphore in. Also,")
 (code:comment "handle the case where a user is not already in the hashes.")
 (code:comment "")
 
 (require racket/splicing semaphore-utils)

 (splicing-let ([sema (make-semaphore 1)]
                [name->dept-id  (make-hash (list (cons 'alice 1) (cons 'bill 1) (cons 'charlie 2)))]
                [dept-id->names (make-hash (list (cons 1 (set 'alice 'bob))  (cons 2 (set 'charlie))))])
   
   (define (get-dept-id name [sema sema])
     (call/sema sema (thunk (hash-ref name->dept-id name))))
     
   (define (get-users dept-id [sema sema])
     (call/sema sema (thunk (hash-ref dept-id->names dept-id))))
   
   (define (add-user! name dept-id)
     (call/sema sema
                (thunk
                 (hash-set! name->dept-id name dept-id)
                 (hash-set! dept-id->names
                            dept-id
                            (code:comment "(set-add (get-users dept-id) name)))))  ; WRONG!  This will deadlock! `sema` is already in use!")
                            (code:comment "Pass #f as the semaphore so that we don't deadlock")
                            (set-add (get-users dept-id #f) name)))))
   )

 (code:comment "")
 (code:comment "If the following functions were running in different threads, the call/sema code would ensure that the 'get-*' functions")
 (code:comment "did not interleave with a call to 'add-user!' and thereby see inconsistent state")
 (define alice-dept-id (get-dept-id 'alice))
 (get-users alice-dept-id)
 (add-user! 'evan alice-dept-id)
 (get-users alice-dept-id)
 ]
