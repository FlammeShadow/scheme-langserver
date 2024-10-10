(library (scheme-langserver protocol apis document-highlight)
  (export 
    find-highlight)
  (import 
    (chezscheme) 

    (ufo-match)
    (scheme-langserver analysis workspace)
    (scheme-langserver analysis identifier reference)
    (scheme-langserver analysis dependency file-linkage)

    (scheme-langserver protocol alist-access-object)

    (scheme-langserver util association)
    (scheme-langserver util path) 
    (scheme-langserver util dedupe) 
    (scheme-langserver util io)

    (scheme-langserver virtual-file-system index-node)
    (scheme-langserver virtual-file-system document)
    (scheme-langserver virtual-file-system file-node)

    (only (srfi :13 strings) string-prefix?))

; https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_documentHighlight
; in fact, document-highlight is document-scoped find-references
(define (find-highlight workspace params)
  (let* ([text-document (alist->text-document (assq-ref params 'textDocument))]
      [position (alist->position (assq-ref params 'position))]
      ;why pre-file-node? because many LSP clients, they wrongly produce uri without processing escape character, and here I refer
      ;https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#uri
      [pre-file-node (walk-file (workspace-file-node workspace) (uri->path (text-document-uri text-document)))]
      [file-node (if (null? pre-file-node) (walk-file (workspace-file-node workspace) (substring (text-document-uri text-document) 7 (string-length (text-document-uri text-document)))) pre-file-node)]
      [document (file-node-document file-node)]
      [fuzzy (refresh-workspace-for workspace file-node)]
      [index-node-list (document-index-node-list document)]
      [text (document-text document)]
      [bias (document+position->bias document (position-line position) (position-character position))]
      [target-index-node (pick-index-node-from index-node-list bias)]
      [prefix 
        (if target-index-node 
          (if (null? (index-node-children target-index-node)) 
            (annotation-stripped (index-node-datum/annotations target-index-node))
            #f))])
    (if prefix
      (let* ([available-references (find-available-references-for document target-index-node prefix)]
          [target-documents `(,document)]
          [predicate? 
            (lambda (maybe-symbol)
              (if (symbol? maybe-symbol)
                (find 
                  (lambda (identifier) (equal? maybe-symbol identifier))
                  (map identifier-reference-identifier available-references))
                #f))])
        (list->vector 
          (map location->alist 
            (apply append 
              (map 
                (lambda (document) 
                  (apply append 
                    (map 
                      (lambda (index-node) (find-references-in document index-node available-references predicate?))
                      (document-index-node-list document))))
                target-documents)))))
          '#())))
)
