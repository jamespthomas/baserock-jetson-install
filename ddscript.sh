dd if=genivi-new.img of=/dev/sdb2 bs=8M
watch -n5 'kill -USR1 $(pgrep ^dd)'
