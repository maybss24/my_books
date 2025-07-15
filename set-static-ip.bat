@echo off
echo Setting static IP address...
echo Current IP: 192.168.193.200
echo Setting static IP to: 192.168.193.200

netsh interface ip set address name="Ethernet" static 192.168.193.200 255.255.252.0 192.168.192.1
netsh interface ip set dns name="Ethernet" static 192.168.192.1

echo Static IP set successfully!
echo Your IP will now remain 192.168.193.200
pause 