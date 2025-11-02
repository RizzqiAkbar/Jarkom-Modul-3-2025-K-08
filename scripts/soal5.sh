#!/bin/bash
echo "===== [SOAL 5] Testing TXT & PTR Record ====="
echo "Testing dig cincin.k08.com TXT"
dig @192.215.3.101 cincin.k08.com TXT

echo "Testing dig -x 192.215.3.101"
dig -x 192.215.3.101
