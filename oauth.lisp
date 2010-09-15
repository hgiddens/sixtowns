(cl:defpackage :oauth-example
  (:use :cl :cl-oauth))
(cl:in-package :oauth-example)

;;; Endpoints
(defparameter *get-request-token-endpoint* "https://api.twitter.com/oauth/request_token")
(defparameter *auth-request-token-endpoint* "https://api.twitter.com/oauth/authorize")
(defparameter *get-access-token-endpoint* "https://api.twitter.com/oauth/access_token")

(defparameter *key* "key")
(defparameter *secret* "secret")

(defparameter *request-token* nil)
(defparameter *access-token* nil)
(defparameter *consumer-token* (make-consumer-token :key *key* :secret *secret*))

(defun get-access-token ()
  (obtain-access-token *get-access-token-endpoint* *request-token*))
(defun get-request-token ()
  (obtain-request-token *get-request-token-endpoint* *consumer-token*))
(defun run ()
  (setf *request-token* (get-request-token))

  (format t "Please authorize us at ~A~%"
          (puri:uri (make-authorization-uri *auth-request-token-endpoint* *request-token*)))

  (authorize-request-token *request-token*)
  (setf (request-token-verification-code *request-token*) "the pin from the URI above")
  (setf *access-token* (get-access-token))

  (babel:octets-to-string
   (access-protected-resource "http://api.twitter.com/1/statuses/friends_timeline.json"
                              *access-token*)))
