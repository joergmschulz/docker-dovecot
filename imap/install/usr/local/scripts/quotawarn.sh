#!/bin/sh
PERCENT=$1
USER=$2
cat << EOF | /usr/sbin/sendmail $2
Subject: Mailbox Überlauf

Guten Tag $2,
Ihre Mailbox ist jetzt zu  $1 % voll.
Bitte beginnen Sie, Nachrichten zu löschen.

EOF