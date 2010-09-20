#!/bin/zsh

ccl -e '(require :asdf)' \
    -e '(push (merge-pathnames "Source/clbuild/systems/" (user-homedir-pathname)) asdf:*central-registry*)' \
    -e "(dolist (system '(:cl-xmpp-tls :babel :cl-oauth :cxml :cl-containers :anaphora :metatilities :xpath :split-sequence :bordeaux-threads)) (asdf:oos 'asdf:load-op system :verbose nil))" \
    -e '(load "package.lisp")' \
    -e '(load "secret.lisp")' \
    -e '(load "sixtowns.lisp")' \
    -e '(sixtowns::start)'

