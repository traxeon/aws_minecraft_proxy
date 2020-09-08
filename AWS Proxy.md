AWS Proxy


## Setup AWS as a Proxy Server to protect a home Linux Minecraft server ## 
* * *
Note: These instructions focus on the AWS proxy server and do not cover setting Stage up the Minecraft server itself. 

The advantage of using a free instance of an AWS compute node as a proxy is that the instance inherits the reliability and resilience of Amazon cloud service.  The instance is not likely to go offline and the network protections can prevent DDoS and other attacks on the home network.


* * *
Stage 1: 
- [ ] Stage 1: Create an AWS Instance
- [ ] Stage 2: Create an Elastic IP for the instance
- [ ] Stage 3: Setup Dynamic IP for home server
- [ ] Stage 4: Setup AWS firewall for access
- [ ] Stage 5: SSH access to the AWS Instance
- [ ] Stage 6: Install and Configure Proxy
- [ ] Stage 7: Test the Configuration

* * *
**Stage 1: Create an AWS Instance**

1. Sign up for an Amazon AWS Account
2. Search for EC2 (Virtual Servers in the Cloud)

![fb3044a75aa801df2919bd4adb0aa83e.png](../../blob/master/_resources/349533a8040e492b9be1df389736ab97.png)

3. Select Launch Instance

![438fd0ed0b790e1d7513d2b53a3d5e51.png](../../blob/master/_resources/9c7d589a21b5408d96d65a93d280a826.png)

4. Enter ec2 in the search bar and press enter.
5. Select the Amazon Linux 2 AMI (HVM)  - Free tier eligible  (x86 version)

![105638f7b2be7bc78fea8d02603daef0.png](../../blob/master/_resources/b976932520ca483c8cd436975483cfbd.png)

6. Select the t2.micro instance (labeled "free tier eligible")
![a46cca30ea11cf252a145b179be4879e.png](../../blob/master/_resources/6e3b8fbdccb8435d8e11c5d56227e631.png)

7. Select the Review and Launch button (lower right of screen)
![c372544a5281f192434c7e133d50166e.png](../../blob/master/_resources/e0f6114c1c00472b9cd65f036385731f.png)

8. On the next screen select Launch
![77d440ac80c5a99ee0fef14f4960d0ab.png](../../blob/master/_resources/bd3970bc30bb43e484921db3507f231a.png)

9. After this, the prompt will ask to create a key pair.  
- 9a. Provide a Key pair name
- 9b. Download Key Pair
- 9c. Launch Instance
(Remember where you store this file.  You need it for SSH access.)

![f3c1acbbe9f12691475595ac89b0b09d.png](../../blob/master/_resources/d0fa632799b64a5a87aba9023c348227.png)

10. Select View Instances

**Stage 1: Complete.  Instance Created**
* * *
**Stage 2: Create Elastic IP and assign it to the instance.**

Assigning an Elastic IP means the instance will always have the same IP address.  If using the Public IP address on the EC2 instance, any reboot of the server will assign a new IP. Elastic IP avoids this issue.  

When creating an Elastic IP it must be associated to a running instance.  If the Elastic IP exists and no instance is running against it, Amazon will charge a small fee to maintain it.  As of this writing, the Elastic IP is currently free when assigning it to an instance.  We do this first to prevent us from having to reconfigure the proxy later.

1. Select Elastic IPs from the left side of the AWS Console
![0738352fa236e3cbc595905b591f87b1.png](../../blob/master/_resources/6ba859b5b0e04a529cfbfaa8bf0a5201.png)

2. Select Allocate Elastic IP address in the top right
![172c2a32d7263d5b907021acbde19175.png](../../blob/master/_resources/e8973838a4414357add1623f9be4dbb9.png)

3. Leave the defaults on Allocate Elastic IP address screen and select Allocate

4. Select the Elastic IP that was created by checking the box, then in the Actions drop down select Associated Elastic IP address
![f29e51ffc1698247c8235159551f68f2.png](../../blob/master/_resources/a90ef4fb8f1d4cef9b0fcc0f7f301b89.png)

5. On the Associate Elastic IP address page, select the instance you just created and its private IP. Then select the Associate button
![f6818900f2d6178ef1c471de1f3a99b1.png](../../blob/master/_resources/fbf97acd0d8c4808b6479d734a7042cc.png)

6. Return to Instances and your instance should reflect the Elastic IP address you just assigned.
![f95b6c44183f0ec25af667920f002b63.png](../../blob/master/_resources/137cf17cfe3a48dfb1649c0b1a4fae86.png)

This instance is now available using the Elastic IP address established in this step.  It was possible to access it using the previous Public IP that was assigned to the instance.

**Stage 2 Complete: Elastic IP configured and assigned to instance**

**Stage 3: Setup Dynamic IP for home server**
There are two parts to this so that your home IP address will always be accessible to the proxy and to your gamers.

*Part 1: DynamicDNS setup*
Most home internet providers have a dynamic IP address assigned to them.   In order to accomodate for an IP change, we will need to setup a DynamicDNS resolver service.  I actually pay annually for NOIP service.  For the IP address to be updated regularly, a client will need to be installed on the Linux server.  It will periodically update the NOIP service so that your DNS entry will resolve to your home.   Do not use the NOIP software that they provide.  It has historically been insecure.  **ddclient** is a capable and secure client that supports NOIP.  Here is my ddclient configuration on Ubuntu LTS:


```
> sudo cat /etc/ddclient.conf
# /etc/ddclient.conf
daemon=30
syslog=yes
cache=/tmp/ddclient.cache
pid=/var/run/ddclient.pid
wildcard=YES
protocol=noip
use=web
ssl=yes
login=<your-email-login-for-noip>
password='<your-password-for-noip-in-single-quotes'    
<the-fully-qualified-domain-you-created-in-noip>
```
Verify that NOIP is getting the correct address for your home IP.

*Part 2: Port Forwarding*
On your home router, the port forwarding will need to be setup to point to the server you have installed in your home.  If the router supports its, for added security, you want to setup the SOURCE address to be equal to the Elastic IP address you created.  This means, that even though the port forwarding will send all requests interally to your Minecraft server, it will only accept the request that come from your proxy in AWS and block all other connections.

**Stage 3: Complete.  Dynamic DNS setup with daemon and firewall/port forwarding ready**
* * *
**Stage 4: Setup AWS firewall for access**
Next, the AWS instance and its Elastic IP need to be opened up for access to port 25565- the default port used by Minecraft for gameplay.

From the Security Groups menu option, select the "launch-wizard-1" check box and from **Action** select **Edit inbound rules**.

![5da222768a9d18e5836f93e8716eab38.png](../../blob/master/_resources/8c246eb3aae446f7a827203018c95e4a.png)

On the resulting screen, Add rule:
Type: Custom TCP
Port Range: 25565
Source: Custom | 0.0.0.0/0
Description (optional): Minecraft Proxy
SAVE RULE

![60e41251b6dd9c66eaf14d5a0a96e225.png](../../blob/master/_resources/9f7c7cbcdef14f71b8ba1c6dc370d8b2.png)

**Stage 4: Complete. Server Ready to accept connections on port 25565**
* * *
**Stage 5: SSH access to the AWS Instance**
The rest of this configuration will need to be performed by logging directly into the command line of the server instance in AWS.  Using the SSH key file downloaded in stage 1, open your SSH client of choice.  Since I use a Linux desktop, I will use standard terminal.

1. Access the Instance using your SSH key

`> ssh -i <path-to>/<keyfile-downloaded>.pem ec2-user@<your-instance-name>
`
This should drop you right into the command line of your server.

**Stage 5: Complete.  SSH access to AWS server** (that was a short step)
* * *
**Stage 6: Install and Configure Proxy**

1. Install required packages
Next we need to install epel (extra packages for enterprise linux) and sslh (port multiplexer)
- EPEL is needed to be able to install sslh.  
- sslh is going to function as the proxy.

`> sudo amazon-linux-extras install epel`
`> sudo yum install sslh`

2. Configure sslh
In other instructions, there has been reference to /etc/default/sslh.   This is no longer part of the configuration as of this writing.   The file to edit is **/etc/sslh.cfg**.  (Using your favorite editor (vim/ nano) in Linux is not part of this instruction.)

Here is a copy of my configuration with minor edits:

```
verbose: false;
foreground: true;
inetd: false;
numeric: false;
transparent: false;
timeout: 2;
pidfile: "/var/run/sslh.pid"
user: "sslh";

# Change hostname with your external address name.
listen:
(
    { host: "<internal-ip-of-instance>"; port: "25565"; }
);

protocols:
(
     { name: "anyprot"; host: "<noip-domain-for-your-house>"; port: "25565"; }
);
```

The **listen** address is the *internal* IP address (not the public Elastic IP address) since Elastic IP is routing traffic to this internal IP from its public IP address.  The **protocols** should be set for the domain name set up in NOIP (or other provider).  Ports should both be 25565 for listen and protocol.

Also, the pidfile entry is an added entry created. That entry may not be required.

3. Enable and start sslh

We first need to enable the service so that it will start on system restart.  After that, we start the server and check its status.

```
> sudo systemctl enable sslh
> sudo systemctl start sslh
> sudo systemctl status sslh

``` 
This is what successful status check looks like (ip addresses redacted)
![723acbc9d2a850828128634ac45ad19b.png](../../blob/master/_resources/eebdc198645246ab8950728b9c7aef98.png)

If you get an error message, then its likely a misconfiguration in the /etc/sslh.cfg file.

**Stage 6: Complete.  Proxy configured and ready for connections**
* * *
**Stage 7: Test the Configuration**

At this point... 
- The AWS server is online and ready to accept connections. 
- The proxy is ready to forward those requests to the home ip which was made accessible by the DynamicDNS client.
- Your home router is configured to allow connections and forward them to your server

Launch Minecraft and under Multiplayer > Direct Connection use the AWS domain name shown in Instances.   

Note: If you prefer something simpler than the AWS domain name (since you will likely give it to friends), I recommend creating a CNAME record in NOIP.  This allows the simpler "noip name" to point to the Elastic IP domain name.  Because this IP will never change, you will not need to install a DynamicDNS client on the AWS server to update the IP registration.

**Stage 7: Complete.  Your Minecraft server is now protected through AWS services.**
* * *
Security notes:
By not publishing your home ip address for your Minecraft server, it reduced the amount of probing that might occur on your home IP.  In addition, by specifying the AWS server ONLY in your port forwarding rules for incoming connections, you block a lot of additional probing.
* * *

## Logical View
Note: The following view does not represent the actual routing of traffic, but rather reflects the logical flow. 

![cd3cab71d8149706d54f4fdf5ddd19e3.png](../../blob/master/_resources/a78f441206894d3d9e3dc61838f0c150.png)










