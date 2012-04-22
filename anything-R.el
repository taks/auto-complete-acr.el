;;; anything-R.el --- anything-sources and some utilities for GNU R.

;; Copyright (C) 2010 myuhe <yuhei.maeda_at_gmail.com>
;; Author: <yuhei.maeda_at_gmail.com>
;; Keywords: convenience,anything, GNU R

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; It is necessary to Some Anything and ESS Configurations for using R before

;;; Installation:
;;
;; Put the anything-R.el, anything.el and ESS to your
;; load-path.
;; Add to .emacs:
;; (require 'anything-R)
;;

;;; Command:
;;  `anything-for-R'

;;  Anything sources defined :
;; `anything-c-source-R-help'     (manage help function)
;; `anything-c-source-R-local'    (manage object))
;; `anything-c-source-R-localpkg' (manage local packages)
;; `anything-c-source-R-repospkg' (manage repository packages)

;;; Code:
(require 'anything)
(require 'ess-site)

(defvar anything-R-default-limit
  anything-candidate-number-limit)

(defvar anything-R-help-limit
  anything-R-default-limit)

(defvar anything-R-local-limit
  anything-R-default-limit)

(defvar anything-R-localpkg-limit
  anything-R-default-limit)

(defvar anything-R-repospkg-limit
  anything-R-default-limit)


(defun anything-R-cmd-head10 (obj-name)
  (ess-execute (concat "head(" obj-name ", n = 10)\n") nil (concat "R head: " obj-name)))

(defun anything-R-cmd-head100 (obj-name)
  (ess-execute (concat "head(" obj-name ", n = 100)\n") nil (concat "R head: " obj-name)))

(defun anything-R-cmd-tail (obj-name)
  (ess-execute (concat "tail(" obj-name ", n = 10)\n") nil (concat "R tail: " obj-name)))

(defun anything-R-cmd-str (obj-name)
  (ess-execute (concat "str(" obj-name ")\n") nil (concat "R str: " obj-name)))

(defun anything-R-cmd-summary (obj-name)
  (ess-execute (concat "summary(" obj-name ")\n") nil (concat "R summary: " obj-name)))

(defun anything-R-cmd-print (obj-name)
  (ess-execute (concat "print(" obj-name ")\n") nil (concat "R object: " obj-name)))

(defun anything-R-cmd-dput (obj-name)
  (ess-execute (concat "dput(" obj-name ")\n") nil (concat "R dput: " obj-name)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;anything-c-source-R-help
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq anything-c-source-R-help
      `((name . "R objects / help")
        (init . (lambda ()
                  (ess-force-buffer-current "Process to load into: ")
                  (let ((ess-proc ess-local-process-name))
                    (if ess-proc
                        (condition-case nil
                            (with-current-buffer (anything-candidate-buffer 'local)
                              (insert
                               (mapconcat 'identity (ess-get-object-list ess-proc) "\n"))))
                      (error nil)))))
        (candidates-in-buffer)
        (candidate-number-limit . ,anything-R-help-limit)
        (action
         ("help" . ess-display-help-on-object)
         ("head (10)" . anything-R-cmd-head10)
         ("head (100)" . anything-R-cmd-head100)
         ("tail" . anything-R-cmd-tail)
         ("str" . anything-R-cmd-str)
         ("summary" . anything-R-cmd-summary)
         ("view source" . anything-R-cmd-print)
         ("dput" . anything-R-cmd-dput))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; anything-c-source-R-local
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq anything-c-source-R-local
      `((name . "R local objects")
        (init . (lambda ()
                  ;; this grabs the process name associated with the buffer
                  (setq anything-c-ess-local-process-name ess-local-process-name)
                  ;; this grabs the buffer for later use
                  (setq anything-c-ess-buffer (current-buffer))))
        (candidates . (lambda ()
                        (let (buf)
                          (condition-case nil
                              (with-temp-buffer
                                (progn
                                  (setq buf (current-buffer))
                                  (with-current-buffer anything-c-ess-buffer
                                    (ess-command "print(ls.str(all.names = TRUE), max.level=0)\n" buf))
                                  (split-string (buffer-string) "\n" t)))
                            (error nil)))))
        (candidate-number-limit . ,anything-R-local-limit)
        (display-to-real . (lambda (obj-name) (car (split-string obj-name " : " t))))
        (action
         ("str" . anything-R-cmd-str)
         ("summary" . anything-R-cmd-summary)
         ("head (10)" . anything-R-cmd-head10)
         ("head (100)" . anything-R-cmd-head100)
         ("tail" . anything-R-cmd-tail)
         ("print" . anything-R-cmd-print)
         ("dput" . anything-R-cmd-dput))
        (volatile)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; func for action
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun anything-ess-marked-install (candidate)
  (dolist (i (anything-marked-candidates))
    (ess-execute (concat "install.packages(\"" i "\")\n") t)))

(defun anything-ess-marked-remove (candidate)
  (dolist (i (anything-marked-candidates))
    (ess-execute (concat "remove.packages(\"" i "\")\n") t)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; anything-c-source-R-localpkg
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq anything-c-source-R-localpkg
      `((name . "R-local-packages")
        (init . (lambda ()
                  ;; this grabs the process name associated with the buffer
                  (setq anything-c-ess-local-process-name ess-local-process-name)
                  ;; this grabs the buffer for later use
                  (setq anything-c-ess-buffer (current-buffer))))
        (candidates . (lambda ()
                        (let (buf)
                          (condition-case nil
                              (with-temp-buffer
                                (progn
                                  (setq buf (current-buffer))
                                  (with-current-buffer anything-c-ess-buffer
                                    (ess-command "writeLines(paste('', sort(.packages(all.available=TRUE)), sep=''))\n" buf))

                                  (split-string (buffer-string) "\n" t)))
                            (error nil)))))
        (candidate-number-limit . ,anything-R-localpkg-limit)
        (action
         ("load packages" . (lambda(obj-name)
                              (ess-execute (concat "library(" obj-name ")\n") t )))
         ("remove packages" . (lambda(obj-name)
                                (ess-execute (concat "remove.packages(\"" obj-name "\")\n") t)))
         ("remove marked packages" . anything-ess-marked-remove))    
        (volatile)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; anything-c-source-R-repospkg
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq anything-c-source-R-repospkg
      `((name . "R-repos-packages")
        (init . (lambda ()
                  ;; this grabs the process name associated with the buffer
                  (setq anything-c-ess-local-process-name ess-local-process-name)
                  ;; this grabs the buffer for later use
                  (setq anything-c-ess-buffer (current-buffer))))
        (candidates . (lambda ()
                        (let (buf)
                          (condition-case nil
                              (with-temp-buffer
                                (progn
                                  (setq buf (current-buffer))
                                  (with-current-buffer anything-c-ess-buffer
                                    (ess-command "writeLines(paste('', rownames(available.packages(contriburl=contrib.url(\"http://cran.md.tsukuba.ac.jp/\"))), sep=''))\n" buf))
                                  ;; (ess-command "writeLines(paste('', sort(.packages(all.available=TRUE)), sep=''))\n" buf))
                                  (split-string (buffer-string) "\n" t)))
                            (error nil)))))
        (candidate-number-limit . ,anything-R-repospkg-limit)
        (action
         ("install packages" . (lambda(obj-name)
                                 (ess-execute (concat "install.packages(\"" obj-name "\")\n") t)))
         ("install marked packages" . anything-ess-marked-install))    
        (volatile)))

(defcustom anything-for-R-list '(anything-c-source-R-help 
                                 anything-c-source-R-local 
                                 anything-c-source-R-repospkg 
                                 anything-c-source-R-localpkg)
  "Your prefered sources to GNU R."
  :type 'list
  :group 'anything-R)

(defun anything-for-R ()
  "Preconfigured `anything' for GNU R."
  (interactive)
  (anything-other-buffer anything-for-R-list "*anything for GNU R*"))


(provide 'anything-R)
