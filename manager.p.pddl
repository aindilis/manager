; going to want to load everything in here

; verber will handle the waiting between waking the user, etc, the issuing of commands, etc.

; see for npddl, we can handle what to do if we observe the user wake up at such and such a time.

; when the water is out, ask to have water filled


(task empty-air-conditioner-filter)
(task-freq empty-air-conditioner-filter 14)
(task take-out-trash)
(task-freq take-out-trash 7)
(task clean-room)
(task-freq clean-room 7)
(task clean-out-vacuum)
;; (after clean-out-vacuum (use vacuum))
(task clean-immediate-work-area)
(task exercise)
(task typing-tutor)
(task shave)
(task backup-computer)
(task rinse-with-mouthwash)
(task job-searching)
