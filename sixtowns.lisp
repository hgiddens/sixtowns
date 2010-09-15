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
