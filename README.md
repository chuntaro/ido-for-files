# ido-for-files

*buffer-list*, *bookmark*, *recentf*, *files-in-current-dir* の4つの情報源を串刺し検索します。  
最小限のとても単純な実装なので完璧には程遠いですが、ひとまずちゃんと動いてます。  
これ以上は *ido-mode* の制約もあるので *Helm* や *Anything* のようにするには難しいと思いますが、たった100行程度なんで、適宜いじってください。  

*ido-for-files.el* を *load-path* に置いて *init.el* に以下を追加。
```emacs-lisp
(require 'ido-for-files)
(global-set-key (kbd "C-:") 'ido-for-files)
```