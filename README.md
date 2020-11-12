
# OS

We are going with dd-wrt for now, as it seems to support the router better.

# Network

We are using the 10.0.0.0 private network in the following way:

All our nodes will be below within 10.134.0.0/16

10.134.0.0/24 .. Servers and router
10.134.1.0/24 .. Access Points
10.134.2.0/24 .. Clients

Note: The above are not real subnets, we will have one big switched network at the beginning. Those are merely reserved ranges.

# Switch IP Addresses

Stiege 2: 192.168.2.2
Serverraum: 192.168.2.10


# Broken APs

15

# Netgear:

APs >= 1 < 20

# TP-Link

20: MAC:98-DA-C4-15-1C-1E

21: MAC:98-DA-C4-15-1C-DB

22: MAC:68-FF-7B-EF-25-C1

23: MAC:98-DA-C4-15-1D-DD

24: MAC:98-DA-C4-15-07-A2

25: MAC:68-FF-7B-EF-26-06

26: MAC:98-DA-C4-15-11-C5

27: MAC:68-FF-7B-EF-33-C2

28: 1 37

29: 1 34

30: 1 11

31: 1 08

32: 2 08

# Switch IPs:

Passwoerter, wie APs.

Hauptswitch im Serverraum: 10.134.0.100

Stiege1: 10.134.0.101

Stiege2: 10.134.0.102

Stiege2 (obenauf): 10.134.0.112

# Next steps concerning full-declarative reouter settings

Create script to load factory settings.
Create script to change the settings which differ in our system.
Do both for both devices (Netgear and tp-link)
Document in Wiki

How to set up a new device:
  1) Flash factory settings
  2) Flash individual settings.
 
How to change a setting:
  1) Dump current settings
  2) Push to repo
  3) Generate settings script from dump
  4) Change setting
  5) Apply to device
  6) Check if successful
  7) Push new settings to repo
