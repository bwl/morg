;;; early-init.el --- Morg early initialization -*- lexical-binding: t -*-

;; This file is loaded before init.el in Emacs 27+
;; It's the best place for performance optimizations and UI tweaks

;; Disable package.el initialization (we'll use use-package in init.el)
(setq package-enable-at-startup nil)

;; Increase GC threshold during startup for faster loading
;; We'll reset this in init.el after startup
(setq gc-cons-threshold most-positive-fixnum)
(setq gc-cons-percentage 0.6)

;; Disable file-name-handler-alist temporarily for faster startup
(defvar morg--file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

;; Restore defaults after init
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024))  ; 16MB
            (setq gc-cons-percentage 0.1)
            (setq file-name-handler-alist morg--file-name-handler-alist)))

;; Native compilation settings (Emacs 28+)
(when (featurep 'native-compile)
  ;; Silence compiler warnings
  (setq native-comp-async-report-warnings-errors 'silent)
  ;; Set native compilation cache directory
  (when (fboundp 'startup-redirect-eln-cache)
    (startup-redirect-eln-cache
     (convert-standard-filename
      (expand-file-name "var/eln-cache/" user-emacs-directory)))))

;; Prevent UI elements from appearing before init
(setq inhibit-redisplay t)
(setq inhibit-message t)
(add-hook 'window-setup-hook
          (lambda ()
            (setq inhibit-redisplay nil)
            (setq inhibit-message nil)
            (redisplay)))

;; Disable UI elements early (faster than doing it in init.el)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

;; Prevent the glimpse of un-styled Emacs
(setq frame-inhibit-implied-resize t)

;; Load private early-init if exists
(let ((private-early-init (expand-file-name "early-init-private.el" user-emacs-directory)))
  (when (file-exists-p private-early-init)
    (load private-early-init nil t)))

(provide 'early-init)
;;; early-init.el ends here
