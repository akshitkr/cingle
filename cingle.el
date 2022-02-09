;;; cingle.el --- Run c/c++ files with a single keystroke -*- lexical-binding: t -*-

;; Version: 1.0
;; Keywords: single, cingle
;; Author: akshitkr <akshitdotkr@gmail.com>
;; URL: https://github.com/akshitkr/cingle

;; This file is part of cingle

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Run C/C++ files with a single keystroke. This is inspired by the
;; C/C++ Compile run extension on VS Code. I faced a lot of issues
;; using `quickrun' to set up something similar on vterm instead so
;; decided to create a separate package entirely. The code uses clang
;; for now but can be adapted to whatever the user prefers.
;; Requires `vterm' and `clang' to work.
;;; Code:


(defun get-file ()
  "Get the file open in the current window."
  (buffer-file-name
   (window-buffer
    (minibuffer-selected-window))))


(defun cd-string ()
  "Create a shell command which opens the directory of the file"
  (concat
   "cd " (file-name-directory (get-file))))


(defun create-other ()
  "Create a shell command to execute the executable generated."
  (concat "./" (file-name-base (get-file))))

(defun create-string-c ()
  "Create a shell command to run the currently opened c file using clang"
  (concat "clang -Wall -std=c11 "
          (file-name-nondirectory
           (get-file))
          " -o "
          (file-name-base
           (get-file)))
  )


(defun create-string-cpp ()
  "Create a shell command to run the currently opened c++ file using clang++"
  (concat "clang++ -Wall -std=c++11 "
          (file-name-nondirectory
           (get-file))
          " -o "
          (file-name-base
           (get-file)))
  )

(defun create-string-based-on-mode ()
  "decide which function to run depending on major mode"
  (if (derived-mode-p 'c-mode)
      (create-string-c)
    (if (derived-mode-p 'c++-mode)
        (create-string-cpp)
      nil )))



(defun cingle ()
  "Insert current c/c++ file in vterm and compile+run."
  (interactive)
  (require 'vterm)
  (eval-when-compile (require 'subr-x))

  (let ((string-print (create-string-based-on-mode)) (string-end (create-other)) (cd-string (cd-string)) (buf (current-buffer)))
    
    (if (or (derived-mode-p 'c-mode) (derived-mode-p 'c++-mode))

        (progn 

          (unless (get-buffer vterm-buffer-name)
            (vterm))

          (display-buffer vterm-buffer-name t)
          (switch-to-buffer-other-window vterm-buffer-name)
          (vterm--goto-line -1)

          (vterm-send-string cd-string)
          (vterm-send-return)
          
          (vterm-send-string string-print)
          (vterm-send-return)

          (vterm-send-string string-end)
          (vterm-send-return)

          (switch-to-buffer-other-window buf)
          (switch-to-buffer-other-window vterm-buffer-name)
          )
      (message "open a c/c++ buffer to continue")
      ))
  )

(provide 'cingle)

;;; cingle.el ends here
