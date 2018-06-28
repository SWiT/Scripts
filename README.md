# Scripts
Random bash scripts for a fresh linux install

Requirements:
sudo apt install ssmtp
sudo nano /etc/ssmtp/ssmtp.conf

root=postmaster
mailhub=smtp.comcast.net:587
UseSTARTTLS=YES
UseTLS=YES
AuthUser=myaccount@comcast.net
AuthPass=****
hostname=mymachine
FromLineOverride=YES


sudo crontab -e
# m h  dom mon dow   command
0 5 * * * /home/swit/scripts/checkraid.sh > /home/swit/scripts/raid.log 2>&1
0 8 * * 0 /home/swit/scripts/checkraid.sh -e > /home/swit/scripts/raid.log 2>&1



Thanks to:
https://www.laurencegellert.com/2015/02/sending-emails-through-comcast-on-ubuntu-using-ssmtp/