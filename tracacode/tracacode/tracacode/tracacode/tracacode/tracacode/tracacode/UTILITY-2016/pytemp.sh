#!/bin/sh

DATESTAMP=`date +%y%m%d`
SOURCE=`pwd`/$1
cat > $SOURCE  << EOF
#!/urs/bin/env python3
'''
Date: $DATESTAMP
TYPE YOUR SCRIPT INTRO HERE

Zhenning LI
'''
EOF

