(defun org-frdcsa-manager-dialog--subset-select (choices-arg callback-arg &optional selection-arg prompt buffer-name)
 ;; add proper fault tolerance
 (let ((buffer-name (or buffer-name "*Subset Select*")))
  (kmax-edit-temp-buffer buffer-name)
  (manager-ss-mode)

  (setq-local manager-ss-name "First")
  (setq-local manager-ss-buffer-name buffer-name)
  (setq-local manager-ss-choices choices-arg)
  (setq-local manager-ss-selection selection-arg)
  (setq-local manager-ss-index 1)
  (setq-local manager-ss-result nil)
  (setq-local manager-ss-callback callback-arg)

  (manager-ss-display-choices)
  (setq-local buffer-read-only t)
  t))

(define-derived-mode manager-ss-mode
 emacs-lisp-mode "Manager Subset Select"
 "Major mode for selecting subsets of manager-ss-choices
\\{manager-ss-mode-map}"
 (setq case-fold-search nil)

 (define-key manager-ss-mode-map "p" 'manager-ss-previous-entry)
 (define-key manager-ss-mode-map "n" 'manager-ss-next-entry)
 (define-key manager-ss-mode-map "\C-p" 'manager-ss-previous-entry)
 (define-key manager-ss-mode-map "\C-n" 'manager-ss-next-entry)

 (define-key manager-ss-mode-map "x" 'manager-ss-return-result)
 (define-key manager-ss-mode-map "\C-c\C-c" 'manager-ss-return-result)

 (define-key manager-ss-mode-map "g" 'manager-ss-goto-entry)

 (define-key manager-ss-mode-map "s" 'manager-ss-toggle-current-entry-selected)
 (define-key manager-ss-mode-map (kbd "SPC") 'manager-ss-toggle-current-entry-selected)
 (define-key manager-ss-mode-map "\C-m" 'manager-ss-toggle-current-entry-selected)

 (define-key manager-ss-mode-map "a" 'manager-ss-select-all)
 (define-key manager-ss-mode-map "A" 'manager-ss-select-none)
 (define-key manager-ss-mode-map "r" 'manager-ss-reverse-selection)

 (define-key manager-ss-mode-map "v" 'manager-ss-view-selection-list)

 (define-key manager-ss-mode-map "q" 'manager-ss-cancel)
 (define-key manager-ss-mode-map (kbd "ESC") 'manager-ss-cancel)

 (make-local-variable 'manager-ss-name)
 (make-local-variable 'manager-ss-buffer-name)
 (make-local-variable 'manager-ss-choices)
 (make-local-variable 'manager-ss-selection)
 (make-local-variable 'manager-ss-index)
 (make-local-variable 'manager-ss-result)
 (make-local-variable 'manager-ss-callback)

 (setq font-lock-defaults '(subl-font-lock-keywords nil nil))
 (re-font-lock))

(defun manager-ss-display-choices ()
 (interactive)
 (insert "  Select a subset of these items, then press\n")
 (insert "  \"\\C-c\\C-c\" to enter your manager-ss-selection.\n")
 (insert "  You can quit with q or ESC\n\n")
 (let ((i 0))
  (mapcar 
   (lambda (choice)
    (insert
     (let* ((int (cl-incf i)))
      (concat
       (manager-ss-print-selection int)
       " ("
       (prin1-to-string int)
       " "
       (prin1-to-string choice)
       ")\n"
       ))))
   manager-ss-choices))
 (manager-ss-goto-index))

(defun manager-ss-print-selection (i)
 (interactive)
 (if (manager-ss-is-selected i)
  "*"
  " "))

(defun manager-ss-is-selected (i)
 (interactive)
 (cl-subsetp (list (nth (- i 1) manager-ss-choices)) manager-ss-selection))

(defun manager-ss-select-index (i)
 (setq-local manager-ss-selection
  (union (list (nth (- i 1) manager-ss-choices)) manager-ss-selection)))

(defun manager-ss-deselect-index (i)
 (setq-local manager-ss-selection
  (cl-set-difference manager-ss-selection (list (nth (- i 1) manager-ss-choices)))))

(defun manager-ss-toggle-current-entry-selected ()
 (interactive)
 (manager-ss-toggle-index-selected manager-ss-index))

(defun manager-ss-toggle-index-selected (i)
 (if (manager-ss-is-selected i)
  (manager-ss-deselect-index i)
  (manager-ss-select-index i))
 (manager-ss-redisplay-entry i))

(defun manager-ss-redisplay-entry (index)
 ""
 (save-excursion
  (manager-ss-goto-entry-number index)
  (backward-up-list)
  (backward-char 1)
  (set-mark (point))
  (backward-char 1)
  (setq-local buffer-read-only nil)
  (kmax-insert-over-region
   (point)
   (mark)
   (if (manager-ss-is-selected index) "*" " ")
   )
  (setq-local buffer-read-only t)
  ))

(defun manager-ss-set-buffer-read-only ()
 (interactive)
 (kmax-not-yet-implemented))

(defun manager-ss-set-buffer-writable ()
 (interactive)
 (kmax-not-yet-implemented))

(defun manager-ss-goto-beginning-of-entry ()
 ""
 (backward-up-list)
 ;; (kmax-try (forward-char) nil)
 )


(defun manager-ss-next-entry ()
 (interactive)
 (if (< manager-ss-index (length manager-ss-choices))
  (setq-local manager-ss-index (+ manager-ss-index 1)))
 (manager-ss-goto-index))

(defun manager-ss-previous-entry ()
 (interactive)
 (if (> manager-ss-index 1)
  (setq-local manager-ss-index (- manager-ss-index 1)))
 (manager-ss-goto-index))

(defun manager-ss-goto-entry ()
 (interactive)
 ""
 (let* ((temp-choices nil)
	(number
	 (progn
	  (dotimes (i (length manager-ss-choices))
	   (push (prin1-to-string (+ i 1)) temp-choices))
	  (org-frdcsa-manager-dialog--choose (reverse temp-choices)))))
  (manager-ss-goto-entry-number (setq-local manager-ss-index (read number)))))

(defun manager-ss-goto-index ()
 (manager-ss-goto-entry-number manager-ss-index))


(defun manager-ss-goto-entry-number (number)
 (beginning-of-buffer)
 (re-search-forward (concat "^..(" (prin1-to-string number) " "))
 (re-search-backward "(")
 (forward-char))

(defun manager-ss-view-selection-list ()
 ""
 (interactive)
 (see manager-ss-selection))

(defun manager-ss-return-result ()
 (interactive)
 (let ((selection manager-ss-selection)
       (callback manager-ss-callback))
  (manager-ss-cancel)
  ;; (kmax-try 'cmh-modes-disable (quote (list (quote (list no-mt)))))
  ;; (cmh-modes-enable (list 'no-mt))
  ;; (kmax-try 'cmh-modes-disable '('(no-mt)))
  ;; (kmax-try 'cmh-modes-enable '('(no-mt)))
  ;; (see callback)
  (kmax-try callback (list selection))))


(defun manager-ss-select-all ()
 (interactive)
 (dotimes (i (length manager-ss-choices))
  (let ((index (+ i 1)))
   (manager-ss-select-index index)
   (manager-ss-redisplay-entry index))))

(defun manager-ss-select-none ()
 (interactive)
 (dotimes (i (length manager-ss-choices))
  (let ((index (+ i 1)))
   (manager-ss-deselect-index index)
   (manager-ss-redisplay-entry index))))

(defun manager-ss-reverse-selection ()
 (interactive)
 (dotimes (i (length manager-ss-choices))
  (let ((index (+ i 1)))
   (manager-ss-toggle-index-selected index))))

(defun manager-ss-cancel ()
 ""
 (interactive)
 (kill-buffer manager-ss-buffer-name))

(provide 'manager-ss)
