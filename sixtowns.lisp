(cl:in-package :sixtowns)

;;; Additional parameters to define:
;;;  *xmpp-host*
;;;  *xmpp-user*
;;;  *xmpp-pass*
;;;  *xmpp-resource*
;;;  *client-jid*
;;;  *access-token*

(defvar *connection* nil)
(defparameter *check-interval* 60)
(defvar *most-recent-seen* nil)
(defvar *client-available* nil)
(defparameter *entry-uri* "http://api.twitter.com/1/statuses/friends_timeline.atom")

(defun connect ()
  (assert (null *connection*))
  (setf *connection* (aprog1 (xmpp:connect-tls :hostname *xmpp-host*)
                       (xmpp:auth it *xmpp-user* *xmpp-pass* *xmpp-resource* :mechanism :sasl-plain))))

(defun disconnect ()
  (assert (not (null *connection*)))
  (xmpp:disconnect *connection*)
  (nilf *connection*))

(defun entry-url (&key since)
  (if since
      (format nil "~A?since_id=~A" *entry-uri* since)
      *entry-uri*))

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

(defun available-presence-p (presence)
  (with-slots ((show xmpp::show) (type xmpp::type-)) presence
    (and (not show) (not type))))

(defmethod xmpp:handle ((connection xmpp:connection) (presence xmpp:presence))
  (when (equal (xmpp::from presence) *client-jid*)
    (setf *client-available* (available-presence-p presence))))

(defun start ()
  (setf *client-available* nil)
  (connect)
  (bt:make-thread (lambda ()
                    (loop until (not *connection*) do
                          (send-tweets)
                          (sleep *check-interval*))))
  (xmpp:receive-stanza-loop *connection*))

(defun title-for-entry (entry)
  (elt (loop for title across (dom:get-elements-by-tag-name entry "title")
             nconc (loop for child across (dom:child-nodes title)
                         when (eq (type-of child) 'rune-dom::text)
                         collect (dom:data child))) 0))

(defun send-tweets ()
  (when *client-available*
    (loop for entry across (get-entries) do
          (xmpp:message *connection* *client-jid* (title-for-entry entry)))))
