;; Setting up Prodigy

(use-package prodigy)

(prodigy-define-service
  :name "Scala Format"
  :path "/usr/local/bin"
  :command "scalafmt_ng"
  :tags '(scala)
  :stop-signal 'sigkill
  :kill-process-buffer-on-stop t)
