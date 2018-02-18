;;; manager.el --- emacs helpers for manager

;; Copyright (C) 2005  Free Software Foundation, Inc.

;; Author: Jason Sayne <jasayne@frdcsa>
;; Keywords:

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;;

;;; Code:

(defvar manager-start-enabled t)
;; (defvar manager-start-enabled nil)

;; (setq manager-start-enabled t)
;; (setq manager-start-enabled nila)

(setq manager-buffer-name "*manager*")
(setq manager-outgoing-message-queue nil)
(setq manager-last-message-time (float-time))

(global-set-key "\C-cmxs" 'manager-secure-systems)
(global-set-key "\C-cmxp" 'manager-plot-task-context-trends)
(global-set-key "\C-cmxu" 'manager-mark-uea-disconnected)
(global-set-key "\C-cmsc" 'manager-scheduler-edit-crontab)
(global-set-key "\C-cmxd" 'manager-open-dribble-file)
(global-set-key "\C-crery" 'manager-edit-excuses-why)
(global-set-key "\C-crerM" 'manager-edit-programs-to-open)
(global-set-key "\C-crerm" 'manager-see-latest-minor-codebases)
(global-set-key "\C-creri" 'manager-see-latest-internal-codebases)
(global-set-key "\C-crerS" 'manager-search-minor-codebases)
(global-set-key "\C-crerw" 'manager-edit-what-to-do-fun)
(global-set-key "\C-crerW" 'manager-edit-what-to-do-serious)


(defun manager-scheduler-edit-crontab ()
 "Edit the crontab for the Scheduler System"
 (interactive)
 (find-file "/etc/myfrdcsa/manager/crontab"))

(defun manager-secure-systems ()
 "Just run xlock"
 (interactive)
 (shell-command "secure-computer"))

(defun manager-start ()
 "Start all the manager services"
 (interactive)
 ;; (manager-open-dribble-file)
 (manager-start-logging))

(defun manager-open-dribble-file ()
 "open a dribble file for manager based on current session"
 (interactive)
 (manager-recompute-dribble-file)
 (if (y-or-n-p-with-timeout (concat "Open dribble file: " manager-dribble-file "? ") 10 nil)
  (open-dribble-file manager-dribble-file)))

(defun manager-compute-dribble-file ()
 "open a dribble file for manager based on current session"
 (interactive)
 ;; determine the current file-number
 (if (not (boundp 'manager-dribble-file))
  (manager-recompute-dribble-file)))

(defun manager-recompute-dribble-file ()
 "open a dribble file for manager based on current session"
 (interactive)
 ;; determine the current file-number
 (let*
  ((greatest (- (manager-select-latest "/var/lib/myfrdcsa/codebases/internal/manager/data/emacs-logs/ttyrec" 0 nil ".ttyrec") 1))
   (dribble-file (concat "/var/lib/myfrdcsa/codebases/internal/manager/data/emacs-logs/dribble/" (int-to-string greatest) ".dribble"))
   (ttyrec-file (concat "/var/lib/myfrdcsa/codebases/internal/manager/data/emacs-logs/ttyrec/" (int-to-string greatest) ".ttyrec"))
   (context-file (concat "/var/lib/myfrdcsa/codebases/internal/manager/data/emacs-logs/context/" (int-to-string greatest) ".context")))
  (progn
   (setq manager-dribble-file dribble-file)
   (setq manager-ttyrec-file ttyrec-file)
   (setq manager-context-file context-file)
   )))

(defun manager-start-logging ()
 (interactive)
 ;; when Emacs is started, there should be an event logged.
 ;; first-change-hook, find-file-hooks, kill-buffer-hooks,
 ;; after-save-hook
 (manager-compute-dribble-file)
 ;; (add-hook 'find-file-hooks 'manager-check-windows)
 ;; (add-hook 'kill-buffer-hook 'manager-check-windows)
 (add-hook 'find-file-hook 'manager-find-file-hook)
 (add-hook 'kill-buffer-hook 'manager-kill-buffer-hook)
 (setq manager-logging-timer
  (run-at-time "1 sec" 1 'manager-update)))

(defun manager-mark-uea-disconnected ()
 "This is a hack, can't seem to get it to realize when its
disconnected, but to prevent this from causing problems, at least
until edits are done on unilang, simply tell it"
 (interactive)
 (setq uea-connected nil))

(defun manager-find-file-hook ()
 (if (and
      (boundp 'uea-connected)
      uea-connected)
  (let*
   ((filename (buffer-file-name (current-buffer))))
   (if filename
    (manager-log-buffer-event "opened" filename)))))

(defun manager-kill-buffer-hook ()
 (if (and
      (boundp 'uea-connected)
      uea-connected)
  (let*
   ((filename (buffer-file-name (current-buffer))))
   (if filename
    (manager-log-buffer-event "closed" filename)))))

(defun manager-stop-logging ()
 (interactive)
 (cancel-timer manager-logging-timer))

(defun manager-select-latest (directory initiali prefix postfix)
 "Choose the latest file to be sent"
 (let*
  ((i initiali)
   (item
    (if
     (or
      (file-exists-p
       (concat directory "/" prefix (int-to-string initiali) postfix))
      (file-exists-p
       (concat directory "/" prefix (int-to-string initiali) postfix ".gz")))
     (progn
      (while
       (or
	(file-exists-p
	 (concat directory "/" prefix (format "%d" i) postfix))
	(file-exists-p
	 (concat directory "/" prefix (format "%d" i) postfix ".gz")))
       (progn
	(setq i (1+ i))))))))
  i))

(defun manager-log-buffer-event (action filename)
 ""
 (interactive)
 (if filename
  (manager-send-message
   (concat "-e "
    (join ","
     (list
      (number-to-string (float-time))
      (join "::"
       (list
	action
	filename
	(if (nth 7 (file-attributes manager-dribble-file))
	 (int-to-string (nth 7 (file-attributes manager-dribble-file)))
	 "0")
	(if (nth 7 (file-attributes manager-ttyrec-file))
	 (int-to-string (nth 7 (file-attributes manager-ttyrec-file)))
	 "0"))
       ))) "\n"))))

(defun manager-send-message (string)
 (if (> (- (float-time) manager-last-message-time) 0.75)
  (progn
   (uea-send-contents string "ELog" "$VAR1 = {_DoNotLog => 1}")
   ;; (uea-send-contents string "UniLang-Client")
   (setq manager-last-message-time (float-time)))
  (push string manager-outgoing-message-queue)))

(defun manager-update ()
 "send any queued messages"
 (if (> (length manager-outgoing-message-queue) 0)
  (manager-send-message
   (pop manager-outgoing-message-queue)))
 (manager-check-windows))

(defun manager-check-windows ()
 "Since there do not appear to be any hooks relating to burying and
raising buffers, we'll just iterate over them every now and then, and
log any changes"
 (interactive)
 ;;  (message "hi")
 ;;  (sit-for 0.2)
 (if (not (boundp 'manager-window-hash))
  (progn
   ;; (setq manager-window-hash (manager-create-filename-hash))
   ;; (makunbound 'manager-window-hash)
   (setq manager-window-hash (make-hash-table :test 'equal))
   ))
 (let*
  ((h (manager-create-filename-hash)))
  (maphash
   (function
    (lambda (key value)
     (if (not (gethash key manager-window-hash nil))
      (manager-log-buffer-event "display" key))
     ))
   h)
  (maphash
   (function
    (lambda (key value)
     (if (not (gethash key h nil))
      (manager-log-buffer-event "conceal" key))
     ))
   manager-window-hash)
  (setq manager-window-hash h)))

(defun manager-create-filename-hash ()
 ""
 (let*
  ((h (make-hash-table :test 'equal)))
  (walk-windows
   (function
    (lambda (w)
     (let*
      ((f (buffer-file-name (window-buffer w))))
      (puthash f t h)
      ))))
  h))

(defun manager-print-hash ()
 ""
 (interactive)
 (maphash
  (function
   (lambda (x y)
    (message x)
    (sit-for 0.5)
    (message "then")
    (sit-for 0.5)
    ))
  manager-window-hash)
 (message "done"))

(defun manager-plot-task-context-trends ()
 ""
 (interactive)
 ;; same stuff as sinless-plotting here.
 (manager-run "--contexts"))

(defun manager-run (arg)
 "Sufficient time has passed, ask whether they have committed any other sins"
 (interactive)
 (let ((buf (get-buffer-create manager-buffer-name)))
  (assert (and buf (buffer-live-p buf)))
  (pop-to-buffer buf)
  (erase-buffer)
  (comint-mode)
  (start-process "manager" manager-buffer-name "manager" arg)))

(provide 'manager)
;;; manager.el ends here

(if manager-start-enabled
 (manager-start))

(defun manager-todo-edit-crontab ()
 ""
 (interactive))

(defun org-frdcsa-manager-dialog-choose (choices &optional prompt)
 ;; add proper fault tolerance
 (case (length choices)
  (0 nil)
  (1 (car choices))
  (otherwise (completing-read (or prompt "Choose: ") choices))
  ))

(defun org-frdcsa-manager-dialog--choose (choices &optional prompt)
 (if (boundp 'prompt)
  (org-frdcsa-manager-dialog-choose choices prompt)
  (org-frdcsa-manager-dialog-choose choices)
  ))

(defun org-frdcsa-manager-dialog--choose-by-processor (choices processor &optional prompt)
 ;; add proper fault tolerance
 (case (length choices)
  (0 nil)
  (1 (car choices))
  (otherwise 
   (let* ((processed-to-choices-hash-table (make-hash-table :test 'equal)))
    (mapcar (lambda (choice) (puthash (apply processor (list choice)) (prin1-to-string choice) processed-to-choices-hash-table)) choices)
    (see (gethash (completing-read (or prompt "Choose: ") (mapcar processor choices)) processed-to-choices-hash-table))
    ))))

(defun manager-edit-programs-to-open ()
 "Jump to the latest version of the log file"
 (interactive)
 (ffap "/var/lib/myfrdcsa/codebases/internal/manager/programs-to-open.notes"))

(defun manager-edit-what-to-do-fun (arg)
 "Jump to the latest version of the what-to-do file"
 (interactive "P")
 (if arg
  (ffap "/var/lib/myfrdcsa/codebases/minor/what-to-do/what-to-do-fun.flr")
  (ffap "/home/andrewdo/Media/projects/people/Meredith-McGhan/projects/gobby/Fun-Stuff-To-Do.notes")))

(defun manager-edit-excuses-why ()
 "Jump to the latest version of the what-to-do file"
 (interactive)
 (ffap "/var/lib/myfrdcsa/codebases/internal/manager/excuses-why.notes"))

(defun manager-edit-what-to-do-serious ()
 "Jump to the latest version of the what-to-do file"
 (interactive)
 (ffap "/var/lib/myfrdcsa/codebases/minor/what-to-do/what-to-do-serious.flr"))

(defun manager-see-latest-minor-codebases ()
 ""
 (interactive)
 (if (kmax-buffer-exists-p "minor</var/lib/myfrdcsa/codebases>")
  (pop-to-buffer (get-buffer "minor</var/lib/myfrdcsa/codebases>"))
  (progn
   (dired "/var/lib/myfrdcsa/codebases/minor")
   (dired-sort-toggle-or-edit)
   (beginning-of-buffer)
   (dired-next-line 2))))

(defun manager-see-latest-internal-codebases ()
 ""
 (interactive)
 (if (kmax-buffer-exists-p "releases</var/lib/myfrdcsa/codebases>")
  (pop-to-buffer (get-buffer "releases</var/lib/myfrdcsa/codebases>"))
  (progn
   (dired "/var/lib/myfrdcsa/codebases/releases")
   (dired-sort-toggle-or-edit)
   (beginning-of-buffer)
   (dired-next-line 2))))

(defun manager-search-minor-codebases ()
 ""
 (interactive)
 (if (kmax-buffer-exists-p "minor</var/lib/myfrdcsa/codebases>")
  (pop-to-buffer (get-buffer "minor</var/lib/myfrdcsa/codebases>"))
  (dired "/var/lib/myfrdcsa/codebases/minor")
  (kmax-search-dired)))

;; (manager-approve-commands (list "ls"))

(defun manager-approve-commands (commands &optional message-arg method-arg auto-approve)
 (interactive)
 (let* ((potential-message
	 (concat
	  "Approve Commands:\n"
	  (join "\n" (mapcar (lambda (command) (concat "\t" command)) commands))
	  "\n"))
	(message
	 (or
	  message-arg
	  potential-message))
	(method (or method-arg 'parallel)))
  (message potential-message)
  (if (eq method 'parallel)
   (if (yes-or-no-p message)
    (mapcar #'shell-command commands))
   (if (eq method 'serial)
    (kmax-not-yet-implemented)))))

(defun org-frdcsa-manager-dialog-file-chooser (&optional choices prompt)
 ""
 (interactive)
 ;; org-frdcsa-manager-dialog-choose
 (read-from-minibuffer (or prompt "Choose filename: ")))

(add-to-list 'load-path "/var/lib/myfrdcsa/codebases/internal/manager/frdcsa/emacs")
(require 'manager-ss)
(require 'manager-tasks)

(provide 'manager)
