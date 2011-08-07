(require 'asm-mode)
(require 'comint)

(defvar *lua-process-buffer* nil
  "Buffer used for communication with SPIM subprocess")

(defun spim-mode ()
  (interactive)
  (asm-mode)
  (setq mode-name "Assembler+SPIM")
  (define-key asm-mode-map (kbd "C-c C-l") 'spim-exec-file)
  (use-local-map (nconc (make-sparse-keymap) asm-mode-map)))

(defun spim-exec-file ()
  (interactive)
  (when (buffer-name *lua-process-buffer*)
    (kill-buffer *lua-process-buffer*))
  (progn
    (setq *lua-process-buffer* (apply 'make-comint "spim" "spim" nil '())) 
    (delete-other-windows)
    (switch-to-buffer-other-window *lua-process-buffer*)
    (other-window -1))
  (flet ((send-command (command)
		       (comint-send-string (get-buffer-process *lua-process-buffer*) command)))
    (send-command (format "load \"%s\"\n" (buffer-file-name (current-buffer)))) 
    (send-command "run\n")))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.as$" . spim-mode))

(provide 'spim-mode)
