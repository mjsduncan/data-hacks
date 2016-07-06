#!/usr/local/bin/guile \
-e main -s
!#
;;
;; this was adapted from /opencog/opencog/nlp/scm/ processing-utils.scm
;;
; generate utterance type tags for file of sentences
; Prior to running this, the RelEx parse server needs to be set up,
; so that the `nlp-parse` call succeeds.
; run /home/relex/opencog-server.sh
; run `guile -l run-r2l.scm`
; On the other hand, if you are running this from the OpenCog docker container,
; you can skip this step as the RelEx parse server will be started automatically
; along with the container. You may need to set the `relex-server-host` if you
; get a "Connection refused" error. For more information:
; https://github.com/opencog/docker/tree/master/opencog/README.md

; Load the needed modules! already loaded by run-r2l.scm
; run-r2l.scm :
(use-modules (ice-9 readline)
	     (ice-9 popen)    ; needed for open-pipe, close-pipe
             (rnrs io ports)  ; needed for get-line
)
; For users who are not aware of readline ...
(activate-readline)

; Stuff actually needed to get r2l running...
(use-modules (opencog) (opencog nlp))

; The primary R2L wrapper is actually in the chatbot dir.
(use-modules (opencog nlp chatbot))
(use-modules (opencog nlp relex2logic))

(load-r2l-rulebase)

; given a file x.txt, generate x.type with "declarative", "interrogative", or "imparative" on corresponding line
;(cog-name (car (sentence-get-utterance-type (car (nlp-parse "get the ball")))))
; $7 = "ImperativeSpeechAct"

; get sentence type from nlp-parse
(define (nlp-parse-type string)
  (catch #t
	 (lambda () 
	   (cog-name (car
		      (sentence-get-utterance-type
		       (car (nlp-parse string))
		       )
		      )
		     )
	   )
	 (lambda (key . parameters)
	   (quote "parse fail")
	   )
	 )
  )
;get list of types from file of sentences
; -----------------------------------------------------------------------
(define (nlp-parse-type-from-file filepath)
  (let*
      (
       (cmd-string (string-join (list "cat " filepath) ""))
       (port (open-input-pipe cmd-string))
       (line (get-line port))
       (out '())
       )
    (while (not (eof-object? line))
	   (set! out (append out (list line)))
	   (set! line (get-line port))		 	     
	   )
    (close-pipe port)
    (map-in-order nlp-parse-type out)
    (display "finished parsing ")
    (display filepath)
    (newline)
    )
  )
; -----------------------------------------------------------------------

;; from directories of aiml files futurist, generic, sophia,
;; plain text files of utterances (one per line) were generated
; get list of .txt files
(use-modules (ice-9 ftw))
(define futurist (cddr (scandir "/home/biocog/R/aiml/data/futurist/text")))

; generate list of utterance types for each text file
(define futurist-types (map nlp-parse-type-from-file futurist))

;; this produces a list of the appropriate length but elements are malformed:
;; (#<unspecified> #<unspecified> #<unspecified> ...)
;; and i couldn't access their content.  the relex parser output shows they are being parsed...

; repeat for each directory
(define generic (scandir "/home/biocog/R/aiml/data/generic/text"))
(define sophia (scandir "/home/biocog/R/aiml/data/sophia/text"))


