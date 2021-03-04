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

(defun asemantic-stickyfunc-scroll-to-func ()
  "Scroll to the currently highlighted function declaration."
  (interactive "@")
  (when asemantic-stickyfunc-current-position
    (goto-char asemantic-stickyfunc-current-position)
    (set-window-start (selected-window) asemantic-stickyfunc-current-position)))

(defun asemantic-stickyfunc-update (window display-start)
  (save-excursion
    (set-buffer (window-buffer window))
    (goto-char display-start)
    (re-search-backward asemantic-stickyfunc-func-regexp (point-min) :noerror)
    (setq asemantic-stickyfunc-current-position (point)
          asemantic-stickyfunc-current (buffer-substring (point) (point-at-eol)))))

;;;###autoload
(define-minor-mode asemantic-stickyfunc-mode
  nil
  :keymap asemantic-stickyfunc-mode-map
  ;;;; Teardown
  (setq header-line-format asemantic-stickyfunc-old-format)
  (remove-hook 'window-scroll-functions #'asemantic-stickyfunc-update :local)
  (when asemantic-stickyfunc-mode
    ;;;; Construction
    (asemantic-stickyfunc-update (selected-window) (window-start))
    (add-hook 'window-scroll-functions #'asemantic-stickyfunc-update nil :local)
    (setq asemantic-stickyfunc-old-format header-line-format
          header-line-format asemantic-stickyfunc-format)))

(provide 'asemantic-stickyfunc)

;;; asemantic-stickyfunc.el ends here
