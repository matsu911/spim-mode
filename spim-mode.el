(require 'asm-mode)
(require 'comint)

(defvar *spim-process-buffer* nil
  "Buffer used for communication with SPIM subprocess")

(defun spim-mode ()
  (interactive)
  (asm-mode)
  (setq mode-name "Assembler+SPIM")
  (define-key asm-mode-map (kbd "C-c C-l") 'spim-exec-file)
  (use-local-map (nconc (make-sparse-keymap) asm-mode-map)))

(defun spim-exec-file ()
  (interactive)
  (flet ((send-command (command)
		       (comint-send-string (get-buffer-process *spim-process-buffer*) command)))
    (when *spim-process-buffer*
      (process-kill-without-query (get-buffer-process *spim-process-buffer*))
      (kill-buffer *spim-process-buffer*))
    (progn
      (setq *spim-process-buffer* (apply 'make-comint "spim" "spim" nil '())) 
      (delete-other-windows)
      (switch-to-buffer-other-window *spim-process-buffer*)
      (other-window -1))
    (send-command (format "load \"%s\"\n" (buffer-file-name (current-buffer)))) 
    (send-command "run\n")))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.as$" . spim-mode))

(provide 'spim-mode)
