;;; ido-for-files.el --- Things like helm-for-files  -*- lexical-binding: t; -*-

;; Copyright (C) 2016 chuntaro

;; Author: chuntaro <chuntaro@sakura-games.jp>
;; Keywords: files, convenience

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

;;; Commentary:

;; `helm-for-files' を `ido-mode' で真似る簡単な実装。

;;; Installation:

;; `ido-for-files.el' を `load-path' に置いて `init.el' に以下を追加。
;; (require 'ido-for-files)
;; (global-set-key (kbd "C-:") 'ido-for-files)

;;; Code:

(require 'ido)
(require 'recentf)
(require 'bookmark)
(require 'cl-lib)

;; 情報源

(cl-defstruct iff-source
  candidates
  action)

(defconst iff-source-buffers-list
  (make-iff-source
   :candidates (lambda ()
                 (mapcar (lambda (buffer)
                           (buffer-name buffer))
                         (buffer-list)))
   :action #'switch-to-buffer))

(defconst iff-source-recentf
  (make-iff-source
   :candidates (lambda ()
                 (unless recentf-list
                   (recentf-mode t))
                 recentf-list)
   :action #'find-file))

(defconst iff-source-bookmarks
  (make-iff-source
   :candidates #'bookmark-all-names
   :action #'bookmark-jump))

(defconst iff-source-files-in-current-dir
  (make-iff-source
   :candidates (lambda ()
                 (directory-files "." t directory-files-no-dot-files-regexp))
   :action #'find-file))

(defvar iff-sources (list iff-source-buffers-list
                          iff-source-recentf
                          iff-source-bookmarks
                          iff-source-files-in-current-dir))

;; 関数

(defun iff-candidates (source)
  "情報源から候補一覧を取得する"
  (funcall (iff-source-candidates source)))

(defun iff-do-action (source choice)
  "情報源のアクションを実行する"
  (funcall (iff-source-action source) choice))

(defun iff-choices-and-nums ()
  "全ての情報源をまとめた選択候補一覧とそれぞれの個数を返す"
  (cl-loop for src in iff-sources
           for candidates = (iff-candidates src)
           append candidates into choices
           collect (length candidates) into nums
           finally return (cons choices nums)))

(defun iff-completing-read (choices)
  "`ido-completing-read'を呼び出すラッパー"
  (ido-completing-read "ido for files: " choices))

(defun iff-position (item seq)
  "文字列リスト内の一致した文字列のインデックスを返す"
  (cl-position item seq :test #'string=))

(defun ido-for-files ()
  "複数の情報源を串刺し検索する"
  (interactive)
  (cl-loop with (choices . nums) = (iff-choices-and-nums)
           with choice = (iff-completing-read choices) ; ido で選択された文字列
           ;; 以下、どの情報源か特定してそのアクションを実行する
           for pos = (iff-position choice choices) then (cl-decf pos num)
           for num in nums
           for src in iff-sources
           when (< pos num) return (iff-do-action src choice)))

(provide 'ido-for-files)
;;; ido-for-files.el ends here
