;; -*- lexical-binding: t; -*-

(use-package calfw)

;; Adding calendar insert
(require 'calendar)

(defun insdate-insert-any-date (date)
  "Insert DATE using the current locale."
  (interactive (list (calendar-read-date)))
  (insert (calendar-date-string date)))

(defun insdate-insert-date-from (&optional days)
  "Insert date that is DAYS from current."
  (interactive (list
                (read-number (format "days: ")
                             0)))
  (insert
   (calendar-date-string
    (calendar-gregorian-from-absolute
     (+ (calendar-absolute-from-gregorian (calendar-current-date))
  	    days))
    t)))

(defun insdate-insert-current-date (&optional omit-day-of-week-p)
  "Insert today's date using the current locale.
  With a prefix argument, the date is inserted without the day of
  the week."
  (interactive "P*")
  (insert (calendar-date-string (calendar-current-date) nil
                                omit-day-of-week-p)))

(global-set-key "\C-x\M-d" `insdate-insert-current-date)

