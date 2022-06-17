#lang info
(define collection "semaphore-utils")
(define deps '("base"))
(define build-deps '("racket-doc"
                     "sandbox-lib"
                     "scribble-lib"
                     "test-more"))
(define scribblings '(("scribblings/semaphore-utils.scrbl" ())))
(define pkg-desc "A small library for working with semaphores.")
(define version "1.0")
(define pkg-authors '("David K. Storrs"))
(define license '(Apache-2.0 OR MIT))
