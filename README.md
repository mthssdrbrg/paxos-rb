paxos-rb
====================

Ruby clone of [Plain Paxos](https://github.com/cocagne/paxos) implementation by Tom Cocagne.

Implementation
--------------

paxos/
------

This module contains the three basic roles in Paxos: Proposer, Acceptor and Learner. Additionally, it contains an aggregation class to compose Proposer, Acceptor, and Learner instances into a single, logical 'Node' class that fullfills the functions of all three roles.

paxos/multi_paxos.rb
--------------------

Class that converts the single-value-only nature of the basic Paxos algorithm into a continual stream of value resolutions which is commonly known as Multi-Paxos. Most practical implementations of Paxos use a variation on the theme of Multi-Paxos.

Testing
-------

Tested using RSpec, however not 100% coverage (yet).
