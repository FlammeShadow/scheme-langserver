(library (scheme-langserver analysis type type-inferencer)
  (export 
    type-inference-for
    construct-substitution-list-for)
  (import 
    (chezscheme)

    (scheme-langserver util dedupe)
    (scheme-langserver util contain)
    (scheme-langserver util cartesian-product)

    (scheme-langserver virtual-file-system index-node)
    (scheme-langserver virtual-file-system document)

    (scheme-langserver analysis identifier reference)
    (scheme-langserver analysis identifier meta)
    
    (scheme-langserver analysis type rules if)
    (scheme-langserver analysis type rules let)
    (scheme-langserver analysis type rules lambda)
    (scheme-langserver analysis type rules trivial)
    (scheme-langserver analysis type rules define)
    (scheme-langserver analysis type rules application)
    ; (scheme-langserver analysis type rules define)

    (scheme-langserver analysis type util)
    (scheme-langserver analysis type walk-engine))

;; We regard the indexes and references as a graph of existed variable and values. 
;; try to get result type by substitution
(define (type-inference-for index-node document)
  (dedupe (reify (document-substitution-list document) index-node)))

(define (construct-substitution-list-for document)
  (document-substitution-list-set! 
    document 
    (append 
      private-initial-type-constraints 
      (apply 
        append
        (map 
          (lambda (index-node)
            (let* ([base (private-construct-substitution-list document index-node '())]
                [extended-base (private-implicit-converte base index-node)])
              extended-base))
          (document-index-node-list document))))))

;gradule typing: unsafe convertion
(define (private-implicit-converte substitutions index-node)
  ; (let ([exported-identifier-references (index-node-references-export-to-other-node index-node)]
  ;     [has-parameter? 
  ;       (fold-left 
  ;         (lambda (prev-result identifier-reference)
  ;           (and prev-result (equal? 'parameter (identifier-reference-type))))
  ;         #t
  ;         exporeted-identifier-references)])
  ;   (if (or (null? exported-identifier-references) (not has-parameter?))
  ;     substitutions
  ;     (if 
  ;         )
  ;   )
  ;   (if (or (null? children) (null? parent))
  ;     substitutions
  ;     (let* ([base (fold-left private-implicit-converte substitutions children)]
  ;         [head-index-node (car children)]
  ;         [rest-index-nodes (cdr children)]
  ;         [reified-head-result (reify base head-index-node)]
  ;         [filtered-lambdas (filter lambda? reified-head-result)])
  ;       (lambda-templates->new-substitution-list 
  ;         base 
  ;         filtered-lambdas 
  ;         rest-index-nodes)))
  substitutions
          ; )
          )

;consistent with meta.sls rnrs-meta-rules.sls
(define private-initial-type-constraints
  (append 
    (map 
      (lambda (identifier) `(,(construct-type-expression-with-meta identifier) < something?))
      '(annotation? assertion-violation? binary-port? boolean? bytevector? cflonum? char? compile-time-value? condition? continuation-condition?
          cost-center? date? eq-hashtable? error? exact? fixnum? flonum? format-condition? fxvector? guadian? hash-table? hashtable? immutable-fxvector?
          immutable-string? immutable-vector? input-port? integer? list? number? output-port? pair? port? procedure? real? something? string? symbol?
          time? vector? void?))
    ;numeric tower
    (list
      `(,(construct-type-expression-with-meta 'fixnum?) < ,(construct-type-expression-with-meta 'bignum?))
      `(,(construct-type-expression-with-meta 'bignum?) < ,(construct-type-expression-with-meta 'integer?))
      `(,(construct-type-expression-with-meta 'integer?) < ,(construct-type-expression-with-meta 'cflonum?))
      `(,(construct-type-expression-with-meta 'cflonum?) < ,(construct-type-expression-with-meta 'flonum?))
      `(,(construct-type-expression-with-meta 'flonum?) < ,(construct-type-expression-with-meta 'rational?))
      `(,(construct-type-expression-with-meta 'rational?) < ,(construct-type-expression-with-meta 'real?))
      `(,(construct-type-expression-with-meta 'real?) < ,(construct-type-expression-with-meta 'complex?))
      `(,(construct-type-expression-with-meta 'complex?) < ,(construct-type-expression-with-meta 'number?)))))

(define (private-construct-substitution-list document index-node base-substitution-list)
  (let* ([children (index-node-children index-node)]
      [children-substitution-list
        (apply 
          append 
          (map 
            (lambda (child) 
              (private-construct-substitution-list document child base-substitution-list))
            children))])
    (fold-left
      (lambda (current-substitutions proc)
        ; (pretty-print proc)
        (filter
          (lambda (a) (not (null? a)))
          (proc document index-node current-substitutions)))
      children-substitution-list
      ;all these processor except trivial-process must add its result to current index-node
      ;such as for (app param ...), app's result type could be (return-type (param-type ...))
      ;must extend substitution with (current-index-node-variable = return-type)
      (list 
        ;this should be the first
        trivial-process

        ;their position and order, I don't care.
        define-process
        let-process
        if-process
        lambda-process

        ;this should be the last
        application-process
      ))))
)