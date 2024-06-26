;;; asemantic-stickyfunc.el --- stickyfunc when there's no semantic -*- lexical-binding: t -*-

;; Author: Will Dey
;; Maintainer: Will Dey
;; Version: 1.0.0
;; Package-Requires: ()
;; Homepage: homepage
;; Keywords: keywords


;; This file is not part of GNU Emacs

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;; Generate README:
;;; Commentary:

;; commentary

;;; Code:

(defgroup asemantic-stickyfunc ()
  ""
  :group 'mode-line)

(defvar asemantic-stickyfunc-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map [header-line down-mouse-1] #'asemantic-stickyfunc-scroll-to-func)
    map))

(defcustom asemantic-stickyfunc-func-regexp "^[^[:blank:]\n]"
  "Regexp to match functions that should be highlighted")

(defvar-local asemantic-stickyfunc-current nil)

(defvar-local asemantic-stickyfunc-current-position nil)

(defvar asemantic-stickyfunc-old-format nil)

(defcustom asemantic-stickyfunc-format '((:propertize " " display ((space :align-to 0)))
                                         (:eval asemantic-stickyfunc-current))
  "Header-line format to use for asemantic-stickyfunc.")

(defcustom asemantic-stickyfunc-delay 0
  "Number of seconds to wait after a scroll event to update the header-line.")

(defun asemantic-stickyfunc-scroll-to-func ()
  "Scroll to the currently highlighted function declaration."
  (interactive "@")
  (when asemantic-stickyfunc-current-position
    (goto-char asemantic-stickyfunc-current-position)
    (set-window-start (selected-window) asemantic-stickyfunc-current-position)
    (setq header-line-format nil)))

(defun asemantic--stickyfunc-update (window display-start)
  (save-excursion
    (set-buffer (window-buffer window))
    (when asemantic-stickyfunc-mode
      (goto-char display-start)
      (if (or (looking-at asemantic-stickyfunc-func-regexp)
	      (= (point) (point-min)))
	  (setq header-line-format nil)
	(re-search-backward asemantic-stickyfunc-func-regexp (point-min) :noerror)
	(setq asemantic-stickyfunc-current-position (point)
	      asemantic-stickyfunc-current (buffer-substring (point) (point-at-eol))
	      header-line-format asemantic-stickyfunc-format)
	(when buffer-face-mode
	  (add-face-text-property 0 (length asemantic-stickyfunc-current)
				  buffer-face-mode-face
				  :append
				  asemantic-stickyfunc-current))))))

(defvar asemantic--stickyfunc-update-timer nil)
(defun asemantic-stickyfunc-update (window display-start)
  (when asemantic--stickyfunc-update-timer
    (cancel-timer asemantic--stickyfunc-update-timer))
  (setq asemantic--stickyfunc-update-timer (run-with-timer
					    asemantic-stickyfunc-delay
					    nil
					    #'asemantic--stickyfunc-update
					    window
					    display-start)))

;;;###autoload
(define-minor-mode asemantic-stickyfunc-mode
  nil
  :keymap asemantic-stickyfunc-mode-map
  ;;;; Teardown
  (remove-hook 'window-scroll-functions #'asemantic-stickyfunc-update :local)
  (setq header-line-format asemantic-stickyfunc-old-format)
  (when asemantic-stickyfunc-mode
    ;;;; Construction
    (setq asemantic-stickyfunc-old-format header-line-format)
    (asemantic-stickyfunc-update (selected-window) (window-start))
    (add-hook 'window-scroll-functions #'asemantic-stickyfunc-update nil :local)))

(provide 'asemantic-stickyfunc)

;;; asemantic-stickyfunc.el ends here
