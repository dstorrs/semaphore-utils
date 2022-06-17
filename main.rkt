#lang racket/base

(require racket/contract)

(provide (all-defined-out))

(define/contract (call/sema sema thnk)
  (-> (or/c #f semaphore?) (-> any) any)
  ; sema can be #f.  This is useful if you have two functions that use
  ; the same sema and one calls the other.  You can let the semaphore
  ; wrap the outer function and pass #f when calling it internally so
  ; that you don't end up deadlocked.
  (if (not sema)
      (thnk)
      (call-with-semaphore
       sema
       thnk)))

(module+ test
  (require test-more)

  (define sema (make-semaphore 1))

  (void (is (call/sema sema (λ () 'ok)) 'ok "base case works"))
  (void (is (call/sema #f (λ () 'ok)) 'ok "calling with #f works"))
  )


