#!/bin/sh
ftp -v -n ds.data.jma.go.jp<<EOF
user jra05814 EemyawW4
binary
cd JRA-55/Hist/Monthly/anl_surf125/
prompt
mget anl_surf125.2016*
bye
EOF
echo "download from ftp successfully"
