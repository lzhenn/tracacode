#!/bin/sh

while true
do
    read -r -p "Delete all wrf inpt/bdy/dda/rst? [Y/n] " input

    case $input in
        [yY][eE][sS]|[yY])
            rm -f wrfbdy*
            rm -f wrffdda*
            rm -f wrfinput*
            rm -f wrflowin*
            rm -f wrfrst*
            break
            ;;

        [nN][oO]|[nN])
            echo "No."
            exit 1          
            ;;

        *)
            echo "Invalid input..."
            ;;
    esac
done

ln -sf $1/wrfbdy* ./
ln -sf $1/wrffdda* ./
ln -sf $1/wrfinput* ./
ln -sf $1/wrflowin* ./
ln -sf $1/wrfrst* ./
