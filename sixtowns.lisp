(cl:defpackage :sixtowns
  (:use :cl))
(cl:in-package :sixtowns)

(defvar *connection* nil)

(defun connect ()
  (assert (null *connection*))
  (let ((connection (xmpp:connect-tls :hostname *xmpp-host*)))
    (xmpp:auth connection *xmpp-user* *xmpp-pass* *xmpp-resource* :mechanism :sasl-plain)
    (setf *connection* connection)))

(defun disconnect ()
  (assert (not (null *connection*)))
  (xmpp:disconnect *connection*)
  (setf *connection* nil))
