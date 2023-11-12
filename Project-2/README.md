

**DOSP Project 2 - Gossip Algorithm**

**Team Members**

● Hrishikesh Mahajan

● Yash Shekhadar

**What is working?**

We were able to run the push sum algorithm and the gossip algorithm for all the possible topologies i.e. mesh (full), line, grid 2d, and imperfect 3d. For the Gossip protocol, each node will converge if it hears a message 10 times and for the Push Sum protocol, each node will converge when the node agrees upon the last 3 values that it heard.

((NewEstimate - OldEstimate) =< 0.00000000001)

Our Observations are as follows:

**Gossip Time Values:** In Report

**Push Sum Time Values:** In Report





**Graphs (Gossip):** In Report

**Graphs (Push Sum):** In Report





**Compilation and Running:**

Enter these commands in this order:

c(master).

c(mainGossip).

c(mainPushSum).

master:init(number of Nodes, topology name, algorithm).

**Insights:**

● The results can be inferred as follows, in mesh (full) topology the convergence time for the smaller node counts is higher as compared to the other topologies however as the size of the network keeps on increasing the performance for mesh will go down.

● Additionally, the line topologies have had the largest time for all topologies and all algorithms since the amount of neighbors it could communicate to was small in the first place.

● Upto 1000 nodes every topology and algorithm perform the same given the power of the computer it is being run on, but so on and so forth there is a divergence in their times of convergence.

**What is the largest network you managed to deal with for each type of topology and**

**algorithm?**

The largest topology we were able to run on a Macbook Pro 16GB with M1 processor was made of 8192 nodes.

