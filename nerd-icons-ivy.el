;;; nerd-icons-ivy.el --- Nerd icons ivy library

;; Copyright (C) 2021 Wizard962 <smatyfei@gmail.com>

;; Author: Wizard962 <smatyfei@gmail.com>
;; Created: 2021/02/14
;; Version: 0.1.0
;; Package-Requires: ((emacs "24.4+"))
;; URL: https://github.com/wizard962/nerd-icons-ivy
;; Keywords: convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Change Log:

;;  0.1.0  2021/02/14 Initial version.

;;; Code:

(require 'nerd-icons)
(require 'ivy)

(defface nerd-icons-ivy-dir-face
  '((((background dark)) :foreground "white")
    (((background light)) :foreground "black"))
  "Face for the dir icons used in ivy"
  :group 'nerd-icons-faces)

(defgroup nerd-icons-ivy nil
  "Shows icons while using ivy and counsel."
  :group 'ivy)

(defcustom nerd-icons-ivy-buffer-commands
  '(ivy-switch-buffer ivy-switch-buffer-other-window counsel-projectile-switch-to-buffer)
  "Commands to use with `nerd-icons-ivy-buffer-transformer'."
  :type '(repeat function)
  :group 'nerd-icons-ivy)

(defcustom nerd-icons-spacer
  "\t"
  "The string used as the space between the icon and the candidate."
  :type 'string
  :group 'nerd-icons-ivy)

(defcustom nerd-icons-ivy-file-commands
  '(counsel-find-file
    counsel-file-jump
    counsel-recentf
    counsel-projectile
    counsel-projectile-find-file
    counsel-projectile-find-dir
    counsel-git)
  "Commands to use with `nerd-icons-ivy-file-transformer'."
  :type '(repeat function)
  :group 'nerd-icons-ivy)

(defun nerd-icons-ivy--buffer-propertize (b s)
  "If buffer B is modified apply `ivy-modified-buffer' face on string S."
  (if (and (buffer-file-name b)
           (buffer-modified-p b))
      (propertize s 'face 'ivy-modified-buffer)
    s))

(defun nerd-icons-ivy--icon-for-mode (mode)
  "Apply `nerd-icons-for-mode' on MODE but either return an icon or nil."
  (let ((icon (nerd-icons-icon-for-mode mode)))
    (unless (symbolp icon)
      icon)))

(defun nerd-icons-ivy--buffer-transformer (b s)
  "Return a candidate string for buffer B named S preceded by an icon.
Try to find the icon for the buffer's B `major-mode'.
If that fails look for an icon for the mode that the `major-mode' is derived from."
  (let ((mode (buffer-local-value 'major-mode b)))
    (format (concat "%s" nerd-icons-spacer "%s")
            (propertize "\t" 'display (or
                                       (nerd-icons-ivy--icon-for-mode mode)
                                       (nerd-icons-ivy--icon-for-mode (get mode 'derived-mode-parent))
                                       ))
            (nerd-icons-ivy--buffer-propertize b s))))

(defun nerd-icons-ivy-icon-for-file (s)
  "Return icon for filename S.
Return the octicon for directory if S is a directory.
Otherwise fallback to calling `nerd-icons-icon-for-file'."
  (cond
   ((string-match-p "\\/$" s)
    (nerd-icons-octicon "file-directory" :face 'nerd-icons-ivy-dir-face))
   (t (nerd-icons-icon-for-file s))))

(defun nerd-icons-ivy-file-transformer (s)
  "Return a candidate string for filename S preceded by an icon."
  (format (concat "%s" nerd-icons-spacer "%s")
          (propertize "\t" 'display (nerd-icons-ivy-icon-for-file s))
          s))

(defun nerd-icons-ivy-buffer-transformer (s)
  "Return a candidate string for buffer named S.
Assume that sometimes the buffer named S might not exists.
That can happen if `ivy-switch-buffer' does not find the buffer and it
falls back to `ivy-recentf' and the same transformer is used."
  (let ((b (get-buffer s)))
    (if b
        (nerd-icons-ivy--buffer-transformer b s)
      (nerd-icons-ivy-file-transformer s))))

;;;###autoload
(defun nerd-icons-ivy-setup ()
  "Set ivy's display transformers to show relevant icons next to the candidates."
  (dolist (cmd nerd-icons-ivy-buffer-commands)
    (ivy-set-display-transformer cmd 'nerd-icons-ivy-buffer-transformer))
  (dolist (cmd nerd-icons-ivy-file-commands)
    (ivy-set-display-transformer cmd 'nerd-icons-ivy-file-transformer)))

(provide 'nerd-icons-ivy)
