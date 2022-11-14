#!/bin/sh
exec /usr/bin/rspamc  -h rspam -P ${RSPAM_Clear_password} learn_spam
