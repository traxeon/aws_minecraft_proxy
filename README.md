UFW firewall configuration

These configuration are required on Debian linux for the ufw to accept LANBroadcast 

```
sudo ufw allow in proto udp to 224.0.0.0/4
sudo ufw allow in proto udp from 224.0.0.0/4
```

To allow IGMP traffic, that must be set up in a different rules location not through ufw commands

Update this file:
/etc/ufw/before.rules

With:
```
# allow IGMP
-A ufw-before-input -p igmp -d 224.0.0.0/4 -j ACCEPT
-A ufw-before-output -p igmp -d 224.0.0.0/4 -j ACCEPT
```
