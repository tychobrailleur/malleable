;; malleable.el --- Moldable Development -*- lexical-binding: t; -*-
(require 'cl-lib)
(require 'url)
(require 's)
(require 'pcsv)
(require 'moldable-emacs)

(defun malleable-malleus-open-link (link _)
;;; TODO
;;; ASk confirmation from user they want to execute, like org-babel
  (string-match "\\([^?]+\\)\\?\\(.*\\)$" link)
  (let ((cmd (match-string 1 link))
        (qs (url-parse-query-string (match-string 2 link))))
    (apply (intern cmd)
           (cl-loop for i in qs collect (cadr i)))))

(org-link-set-parameters "malleus"
                         :follow #'malleable-malleus-open-link)


(defun malleable--pandoc-convert (content from to)
  "Converts CONTENT from format FROM to format TO using pandoc."
  (with-temp-buffer
    (insert content)
    (shell-command-on-region (point-min)
                             (point-max)
                             (format "pandoc -f %s -t %s" from to)
                             (current-buffer)
                             t)
    (buffer-string)))

(defun malleable-fetch-webpage (url)
  "Fetch the content of the page at URL, and returns it as a string."
  (s-trim
   (with-temp-buffer
     (url-insert-file-contents url)
     (buffer-string))))

(defun malleable-html-to-org (html)
  (s-trim (malleable--pandoc-convert html "html" "org")))


;; (malleable-html-to-org
;;  (malleable-fetch-webpage "https://malleable.systems/blog/2020/04/01/the-most-successful-malleable-system-in-history/"))

(defmacro defmalleus (name args &rest body)
  (declare
   (debug defun)
   (doc-string 3)
   (indent 2))
  ;;; TODO
  ;;; set interactive to read arguments when there are some.
  `(defun ,name ,args (interactive) ,@body))

(defmalleus test-it (one two)
  (message (format "[%s]: %s" one two)))

(defmalleus csv-to-plist ()
  (save-excursion
    (goto-char (point-min))
    (let* ((plist (--> (pcsv-parse-buffer)
                       (me-org-table-as-alist-to-plist it))))
      (with-current-buffer (generate-new-buffer "*Malleable*")
        (emacs-lisp-mode)
        (erase-buffer)
        (me-print-to-buffer plist)))))

(provide 'malleable)
