semaphore-utils
===============

Racket library containing utility functions useful for working with
semaphores.

(call/sema sema thnk) ; if sema is #f, do (thnk).  If it is a semaphore, do (call-with-semaphore sema thnk)
