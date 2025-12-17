;; -*- lexical-binding: t; -*-

;;; http-funcs.el --- Provides http functions for decoding/encoding, etc.
;;; Commentary:

;;; Code:

(require 'json)
(require 'url-util)

(defun cal/func-region (start end func)
  "Run a FUNCTION over the region between START and END in current buffer"
  (save-excursion
    (let ((text (delete-and-extract-region start end)))
      (insert (funcall func text)))))

(defun cal/hex-region (start end)
  "urlencode the region between START and END in current buffer"
  (interactive "r")
  (cal/func-region start end #'url-hexify-string))

(defun cal/unhex-region (start end)
  "de-urlencode the region between START and END in current buffer"
  (interactive "r")
  (cal/func-region start end #'url-unhex-string))

(defun cal/make-grafana-queries (datasource pod)
  (let ((queries (make-hash-table :test 'equal))
        (datasource-map (make-hash-table :test 'equal)))
    ;; Create expression
    ;; %S quotes("") the inserted string
    (puthash "expr" (format "{pod=%S}" pod) queries)
    ;; Create datasource
    (puthash "type" datasource datasource-map)
    (puthash "uid" (format "%s-datasource" datasource) datasource-map)
    ;; Create queries
    (puthash "datasource" datasource-map queries)
    (puthash "refId" "A" queries)
    (puthash "editorMode" "code" queries)
    (puthash "direction" "forward" queries)
    (puthash "legendFormat" "" queries)
    (puthash "queryType" "range" queries)
    queries))

(defun cal/make-grafana-range (from to)
  (let ((range (make-hash-table :test 'equal)))
    (puthash "from" from range)
    (puthash "to" to range)
    range))

(defun cal/make-grafana-panels-state ()
  (let ((panels-state (make-hash-table :test 'equal))
        (logs (make-hash-table :test 'equal))
        (columns (make-hash-table :test 'equal)))
    (puthash "0" "Time" columns)
    (puthash "1" "Line" columns)
    (puthash "columns" columns logs)
    (puthash "logs" logs panels-state)
    (puthash "visualizationType" "table" panels-state)
    (puthash "labelFieldName" "labels" panels-state)
    panels-state))

(defun cal/make-grafana-json (datasource pod from to)
  (let ((grafana-json (make-hash-table :test 'equal))
        (panes-json (make-hash-table :test 'equal)))
    (puthash "datasource" datasource grafana-json)
    (puthash "queries" (cons (cal/make-grafana-queries datasource pod) '()) grafana-json)
    (puthash "range" (cal/make-grafana-range from to) grafana-json)
    (puthash "panelsState" (cal/make-grafana-panels-state) grafana-json)
    (puthash "9fy" grafana-json panes-json)
    (json-encode panes-json)))

(defun cal/make-grafana-url (datasource pod from to hexify)
  (let ((url-prefix "http://grafana.k8s.alvoiarko.lan/explore?schemaVersion=1&orgId=1")
        (grafana-json (cal/make-grafana-json datasource pod from to)))
    (if hexify
        (format "%s&panes=%s" url-prefix (url-hexify-string grafana-json))
      (format "%s&panes=%s" url-prefix grafana-json))))
