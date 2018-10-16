#!/bin/bash
# vim-syntax-nginx-deploy.sh; ver 2016-09-16; strachotao
#  bash way deploy

mkdir -p ~/.vim/syntax/

cd ~/.vim/syntax/

wget -O nginx.vim http://www.vim.org/scripts/download_script.php?src_id=19394

cat > ~/.vim/filetype.vim <<EOF
au BufRead,BufNewFile /etc/nginx/*,/usr/local/nginx/conf/* if &ft == '' | setfiletype nginx | endif
EOF
