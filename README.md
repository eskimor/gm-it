
# OS

We are going with dd-wrt for now, as it seems to support the router better.

# Network

We are using the 10.0.0.0 private network in the following way:

All our nodes will be below within 10.134.0.0/16

10.134.0.0/24 .. Servers and router
10.134.1.0/24 .. Access Points
10.134.2.0/24 .. Clients

Note: The above are not real subnets, we will have one big switched network at the beginning. Those are merely reserved ranges.
