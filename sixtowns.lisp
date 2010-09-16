(cl:in-package :sixtowns)

(defvar *connection* nil)

(defun connect ()
  (assert (null *connection*))
  (setf *connection* (aprog1 (xmpp:connect-tls :hostname *xmpp-host*)
                       (xmpp:auth it *xmpp-user* *xmpp-pass* *xmpp-resource* :mechanism :sasl-plain))))

(defun disconnect ()
  (assert (not (null *connection*)))
  (xmpp:disconnect *connection*)
  (nilf *connection*))

(defparameter *entry-uri* "http://api.twitter.com/1/statuses/friends_timeline.atom")

(defun get-entries ()
  "Retrieves a list of atom entries."
  (let ((feed (babel:octets-to-string (cl-oauth:access-protected-resource *entry-uri* *access-token*))))
    (dom:get-elements-by-tag-name (cxml:parse feed (cxml-dom:make-dom-builder)) "entry")))
