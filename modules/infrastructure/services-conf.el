;; Setting up Prodigy

(use-package prodigy)

(prodigy-define-service
  :name "Scala Format"
  :path "/usr/local/bin"
  :command "scalafmt_ng"
  :tags '(scala)
  :stop-signal 'sigkill
  :kill-process-buffer-on-stop t)

(prodigy-define-service
  :name "Jake -> ParamdbInternalDNS"
  :command "bash"
  :args '("-c" "while true; do jake port-forward -s dev ParamdbInternalDNS http; done")
  :tags '(cibo experimentfactory jake)
  :stop-signal 'sigkill
  :kill-process-buffer-on-stop t)

(prodigy-define-service
  :name "Kubectl -> Sylvester"
  :command "bash"
  :args '("-c" "while true; do kubectl port-forward -n sylvester-dev svc/sylvester-dev 8183:80; done")
  :tags '(cibo experimentfactory jake)
  :stop-signal 'sigkill
  :kill-process-buffer-on-stop t)

(prodigy-define-service
  :name "Jake -> ContinuumDBHost"
  :command "bash"
  :args '("-c" "while true; do jake port-forward -s dev ContinuumDBHost postgresql; done")
  :tags '(cibo experimentfactory jake)
  :stop-signal 'sigkill
  :kill-process-buffer-on-stop t)
