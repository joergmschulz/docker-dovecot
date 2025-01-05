#!/bin/bash
PERCENT=$1
USER=$2
cat << EOF | /usr/sbin/sendmail $USER -O "plugin/quota=maildir:User quota:noenforcing"
From: [email protected]
Subject: quota warning

Ihre Mailbox ist jetzt zu  $PERCENT% voll.
EOF