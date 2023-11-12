# DOSP Project Report 3

## Chord Protocol

### Team Members:

		Hrishikesh Mahajan

		Yash Shekhadar

  
  

#### What is working?

  

The chord protocol has been implemented in accordance with the paper titled : Chord: A Scalable Peer-to-peer Lookup Protocol for Internet Applications Actors are being spun up and they are able to assemble themselves into the chord formation, furthermore, they are able to lookup random keys from a given range.

  

The figure 4 in the paper is an accurate representation for our protocol, with front links and backlinks always active. We have implemented dynamic indexing so that it is easier to transition in and out of failure of nodes. Additionally, we have made a recording of how our erlang code behaves over an M1 Macbook Pro with 16 GB of RAM, here are the findings: **(Find in Report)**



  

What is the Largest Network You Managed to Deal with?

  

Largest Network we managed to deal with consisted of 4000 nodes.