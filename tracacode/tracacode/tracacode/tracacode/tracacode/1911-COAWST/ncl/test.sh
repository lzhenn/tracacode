
#!/bin/bash
b=''
i=0
while [ $i -le 100 ]
do
     printf "[%-50s] %d%% \r" "$b" "$i";
      sleep 0.2
       ((i=i+2))
        b+='#'
    done
    echo
