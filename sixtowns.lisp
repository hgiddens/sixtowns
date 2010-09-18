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

(defun entry-url (&key since)
  (if since
      (format nil "~A?since_id=~A" *entry-uri* since)
      *entry-uri*))

(defvar *most-recent-seen* nil)

(defun get-entries ()
  "Retrieves a list of atom entries."
  (let ((feed (babel:octets-to-string (cl-oauth:access-protected-resource (entry-url :since *most-recent-seen*) *access-token*))))
    (aprog1 (dom:get-elements-by-tag-name (cxml:parse feed (cxml-dom:make-dom-builder)) "entry")
      (unless (cl-containers:empty-p it)
        (setf *most-recent-seen* (entry-id (most-recent it)))))))

(defun entry-id (entry)
  (let ((full-id (xpath:with-namespaces (("atom" "http://www.w3.org/2005/Atom"))
                   (xpath:string-value (xpath:evaluate "atom:id" entry)))))
    (cl-containers:last-item (split-sequence:split-sequence #\/ full-id))))

(defun most-recent (entries)
  (elt entries 0))
