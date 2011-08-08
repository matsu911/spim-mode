(require 'asm-mode)
(require 'comint)

(defvar *spim-process-buffer* nil
  "Buffer used for communication with SPIM subprocess")

(defun spim-mode ()
  (interactive)
  (asm-mode)
  (setq mode-name "Assembler+SPIM")
  (define-key asm-mode-map (kbd "C-c C-l") 'spim-load-file)
  (define-key asm-mode-map (kbd "C-c C-i") 'spim-reinitialize)
  (define-key asm-mode-map (kbd "C-c C-r") 'spim-run)
  (define-key asm-mode-map (kbd "C-c C-z") 'spim-display-buffer)
  (use-local-map (nconc (make-sparse-keymap) asm-mode-map)))

(defun spim-send-command (command)
  (comint-send-string (get-buffer-process *spim-process-buffer*) command))

(defun spim-reinitialize ()
  (interactive)
  (unless *spim-process-buffer*
    (spim-create-buffer))
  (spim-send-command "reinitialize\n"))

(defun spim-create-buffer ()
  (setq *spim-process-buffer* (apply 'make-comint "spim" "spim" nil '())) 
  (delete-other-windows)
  (switch-to-buffer-other-window *spim-process-buffer*)
  (other-window -1)) 

(defun spim-load-file ()
  (interactive)
  (unless (and *spim-process-buffer*
	       (buffer-name *spim-process-buffer*))
    (spim-create-buffer))
  (spim-send-command (format "load \"%s\"\n" (buffer-file-name (current-buffer)))) )

(defun spim-run ()
  (interactive)
  (unless (and *spim-process-buffer*
	       (buffer-name *spim-process-buffer*))
    (spim-create-buffer))
  (spim-send-command "run\n"))

(defun spim-display-buffer ()
  (interactive)
  (when (and *spim-process-buffer*
	     (buffer-name *spim-process-buffer*))
    (display-buffer *spim-process-buffer*)))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.as$" . spim-mode))

(provide 'spim-mode)
