;; -*- lexical-binding: t; -*-

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
  :tags '(cibo experimentfactory jake paramdb)
  :stop-signal 'sigkill
  :kill-process-buffer-on-stop t)

;; (prodigy-define-service
;;   :name "Kubectl -> Sylvester"
;;   :command "bash"
;;   :args '("-c" "while true; do kubectl port-forward -n sylvester-dev svc/sylvester-dev 8183:80; done")
;;   :tags '(cibo experimentfactory jake sylvester)
;;   :stop-signal 'sigkill
;;   :kill-process-buffer-on-stop t)

(prodigy-define-service
  :name "Kubectl -> Sylvester INS"
  :command "bash"
  :args '("-c" "while true; do kubectl port-forward -n sylvester-dev svc/sylvester-dev 8183:80; done")
  :tags '(cibo insights jake sylvester)
  :stop-signal 'sigkill
  :kill-process-buffer-on-stop t)

(prodigy-define-service
  :name "Jake -> ContinuumDBHost"
  :command "bash"
  :args '("-c" "while true; do jake port-forward -s dev ContinuumDBHost postgresql; done")
  :tags '(cibo experimentfactory jake continuumdb)
  :stop-signal 'sigkill
  :kill-process-buffer-on-stop t)

;; (prodigy-define-service
;;   :name "Kubectl -> Cropnosis EXP"
;;   :command "bash"
;;   :args '("-c" "while true; do kubectl port-forward -n cropnosis-dev svc/cropnosis-dev 8080:80; done")
;;   :tags '(cibo experimentfactory jake cropnosis)
;;   :stop-signal 'sigkill
;;   :kill-process-buffer-on-stop t)

(prodigy-define-service
  :name "Kubectl -> Cropnosis INS"
  :command "bash"
  :args '("-c" "while true; do kubectl port-forward -n cropnosis-dev svc/cropnosis-dev 8080:80; done")
  :tags '(cibo insights jake cropnosis)
  :stop-signal 'sigkill
  :kill-process-buffer-on-stop t)

(prodigy-define-service
  :name "Kubectl -> Sylvester PostGIS"
  :command "bash"
  :args '("-c" "while true; do kubectl port-forward -n sylvester-dev svc/sylvester-postgres-dev-postgresql 5432; done")
  :tags '(cibo sylvester postgis)
  :stop-signal 'sigkill
  :kill-process-buffer-on-stop t)

(prodigy-define-service
  :name "Bash LSP Docker"
  :command "docker"
  :args '("run" "--rm" "--name" "bash-explainshell" "-p" "5000:5000" "chrismwendt/codeintel-bash-with-explainshell")
  :env '(("EXPLAINSHELL_ENDPOINT" "http://localhost:5000"))
  :tags '(bash lsp)
  :stop-signal 'sigint
  :kill-process-buffer-on-stop t
  :ready-message "waiting for connections on port")
