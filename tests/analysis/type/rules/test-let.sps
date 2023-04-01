#!/usr/bin/env scheme-script
;; -*- mode: scheme; coding: utf-8 -*- !#
;; Copyright (c) 2022 WANG Zheng
;; SPDX-License-Identifier: MIT
#!r6rs

(import 
    ; (rnrs (6)) 
    (chezscheme) 
    (srfi :64 testing) 
    (scheme-langserver virtual-file-system file-node)
    (scheme-langserver virtual-file-system index-node)
    (scheme-langserver virtual-file-system document)
    (scheme-langserver virtual-file-system library-node)

    (scheme-langserver util contain)

    (scheme-langserver analysis package-manager akku)
    (scheme-langserver analysis workspace)
    (scheme-langserver analysis tokenizer)
    (scheme-langserver analysis identifier reference)
    (scheme-langserver analysis identifier meta)
    (scheme-langserver analysis type type-inferencer)
    (scheme-langserver analysis type variable)
    (scheme-langserver analysis type walk-engine)
    (scheme-langserver analysis type util)

    (scheme-langserver protocol alist-access-object))

; (test-begin "test variable declaration")
;     (let* ([workspace (init-workspace (string-append (current-directory) "/util/"))]
;             [root-file-node (workspace-file-node workspace)]
;             [root-library-node (workspace-library-node workspace)]
;             [target-file-node (walk-file root-file-node (string-append (current-directory) "/util/natural-order-compare.sls"))]
;             [target-document (file-node-document target-file-node)]
;             [target-text (document-text target-document)]
;             [target-index-node (pick-index-node-from (document-index-node-list target-document) (text+position->int target-text (make-position 8 20)))]
;             [check-base (construct-type-expression-with-meta 'integer?)])
;         (construct-substitution-list-for target-document)
;         (test-equal #t (contain? (type-inference-for target-index-node target-document) check-base)))
; (test-end)

; (test-begin "test variable access")
;     (let* ([workspace (init-workspace (string-append (current-directory) "/util/"))]
;             [root-file-node (workspace-file-node workspace)]
;             [root-library-node (workspace-library-node workspace)]
;             [target-file-node (walk-file root-file-node (string-append (current-directory) "/util/natural-order-compare.sls"))]
;             [target-document (file-node-document target-file-node)]
;             [target-text (document-text target-document)]
;             [target-index-node (pick-index-node-from (document-index-node-list target-document) (text+position->int target-text (make-position 12 25)))]
;             [check-base (construct-type-expression-with-meta 'integer?)])
;         (construct-substitution-list-for target-document)
;         (test-equal #t (contain? (type-inference-for target-index-node target-document) check-base)))
; (test-end)

; (test-begin "test parameter-index-node type access")
;     (let* ([workspace (init-workspace (string-append (current-directory) "/util/"))]
;             [root-file-node (workspace-file-node workspace)]
;             [root-library-node (workspace-library-node workspace)]
;             [target-file-node (walk-file root-file-node (string-append (current-directory) "/util/natural-order-compare.sls"))]
;             [target-document (file-node-document target-file-node)]
;             [target-text (document-text target-document)]
;             [target-index-node (pick-index-node-from (document-index-node-list target-document) (text+position->int target-text (make-position 8 44)))]
;             [check-base (construct-type-expression-with-meta 'string?)])
;         (construct-substitution-list-for target-document)
;         (test-equal #t (contain? (type-inference-for target-index-node target-document) check-base)))
; (test-end)

(test-begin "test procedure type access")
    (let* ([workspace (init-workspace (string-append (current-directory) "/util/"))]
            [root-file-node (workspace-file-node workspace)]
            [root-library-node (workspace-library-node workspace)]
            [target-file-node (walk-file root-file-node (string-append (current-directory) "/util/natural-order-compare.sls"))]
            [target-document (file-node-document target-file-node)]
            [target-text (document-text target-document)]
            [target-index-node (pick-index-node-from (document-index-node-list target-document) (text+position->int target-text (make-position 4 10)))]
            [check-base (construct-type-expression-with-meta '(boolean? (string? integer?)))])
        (construct-substitution-list-for target-document)
        (pretty-print 'procedure0)
        ; (pretty-print (length (filter pure-variable? (type-inference-for target-index-node target-document))))
        (pretty-print (length (filter pure-identifier-reference? (type-inference-for target-index-node target-document))))
        ; (pretty-print (car (filter (lambda(item) (not (pure-variable? item))) (filter list? (type-inference-for target-index-node target-document)))))
        ; (pretty-print (car (filter pure-identifier-reference? (type-inference-for target-index-node target-document))))
        (pretty-print (cadr (car (filter pure-identifier-reference? (type-inference-for target-index-node target-document)))))
        (pretty-print 'procedure1)
        (pretty-print (cadr check-base))
        (pretty-print (equal? check-base (car (filter pure-identifier-reference? (type-inference-for target-index-node target-document)))))

        (test-equal #t (contain? (type-inference-for target-index-node target-document) check-base)))
(test-end)

(exit (if (zero? (test-runner-fail-count (test-runner-get))) 0 1))
