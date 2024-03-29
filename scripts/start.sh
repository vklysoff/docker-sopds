#!/bin/bash

if [ $MIGRATE == True ]; then
    cd /sopds
    python3 manage.py migrate
fi

# TODO: Надо флаг /sopds/setconf в другое место поместить
if [ ! -f /sopds/setconf ]; then
    cd /sopds
    python3 manage.py sopds_util setconf SOPDS_ROOT_LIB $SOPDS_ROOT_LIB
    python3 manage.py sopds_util setconf SOPDS_INPX_ENABLE $SOPDS_INPX_ENABLE
    python3 manage.py sopds_util setconf SOPDS_LANGUAGE $SOPDS_LANGUAGE

    # Logs to stdout
    python3 manage.py sopds_util setconf SOPDS_SERVER_LOG "/dev/stdout"
    python3 manage.py sopds_util setconf SOPDS_SCANNER_LOG "/dev/stdout"
    python3 manage.py sopds_util setconf SOPDS_TELEBOT_LOG "/dev/stdout"


    #configure fb2converter for epub and mobi - https://github.com/rupor-github/fb2converter
    python3 manage.py sopds_util setconf SOPDS_FB2TOEPUB "convert/fb2c/fb2epub"
    python3 manage.py sopds_util setconf SOPDS_FB2TOMOBI "convert/fb2c/fb2mobi"
    python3 manage.py sopds_util setconf SOPDS_FB2TOXHTML "convert/fb2xhtml/fb2xhtml"

    #autocreate the superuser
    if [[ ! -z $SOPDS_SU_NAME && ! -z $SOPDS_SU_EMAIL &&  ! -z $SOPDS_SU_PASS ]]; then
        expect /sopds/superuser.exp
    fi

    touch /sopds/setconf
fi

#To start the Telegram-bot if it enabled
if [ $SOPDS_TMBOT_ENABLE == True ]; then
    python3 manage.py sopds_telebot start --daemon
fi

python3 manage.py sopds_server start & python3 manage.py sopds_scanner start
