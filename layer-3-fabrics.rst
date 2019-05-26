Layer 3 Fabrics
===============

This blueprint item primarily covers the following topics:

* :ref:`clos`
* :ref:`ip-fabric-routing`
* :ref:`ip-fabric-scaling`
* :ref:`best-practices`

.. _clos:

3-Stage Clos Architecture
-------------------------

A Clos network was originally a circuit switching architecture for the
PSTN.  It provided for connecting one input to one output with no
blocking.  In other words, connectivity was always possible.  This was
because of the intermediate switches that connected ingress and egress
switches.

In IP networking, this concept has been applied in the "spine-leaf"
architecture.  In this design, a number of interconnecting transport
switches (spines) connect to ingress and egress switches (leafs).  They
provide multiple paths for communications and can be designed in a way
that is "non-blocking" if zero oversubscription is desired.  These
fabrics make better use of their links.  They are classified as
``n-stage``, where ``n`` is (more or less) the number of network devices
a packet will traverse when ingressing and egressing from any point in
the fabric to any point in the fabric.  A 3-stage architecture consists
of three network devices from point A to point Z: the ingress leaf, a
spine, and an egress leaf.  This means that you can have predictable
network characteristics such as hop count and latency.  For example, for
intra-fabric communications, any destination is exactly two hops from
its source (excluding advanced services such as overlay networking,
firewalls, load balancers, etc.).

.. _ip-fabric-routing:

IP Fabric Routing
-----------------

When designing an IP fabric, there are two primary designs, though both
leverage BGP.

.. _ibgp:

iBGP
^^^^

In an iBGP design, an IGP such as OSPF or IS-IS is used to provide
multipathing.  iBGP peerings are formed over loopback interfaces, and
route reflectors can be used to increase the scale of the solution.
Route reflection, however, introduces its own issues.

When the same prefix is received from multiple leafs by a route
reflector spine, it will (by default) only advertise the best path to
the non-route-reflector spines.  This results in suboptimal traffic
forwarding, and in congested scenarios may result in avoidable
congestion and degradation of service.  To resolve this issue, BGP
ADD-PATH can be used.  BGP ADD-PATH causes the router to prefix a unique
path identifier to a prefix advertisement; because of this, all routers
at the spine level must support and be configured for BGP ADD-PATH.

.. _ebgp:

eBGP
^^^^

With eBGP, there is no IGP -- BGP acts in a similar role as an IGP.  In
this design, each leaf node is given a unique ASN and all spines either
share the same ASN or have unique ASNs per node.

.. note::
   The QFX5100 Series book [#f1]_, particularly Chapter 7: IP Fabrics
   (Clos), seems to suggest that the spine switches should each have a
   unique ASN.  However, multiple other sources such as RFC7938 [#f2]_
   and BGP in the Data Center [#f3]_ suggest giving the spines the same
   ASN while allowing the leafs to have unique ASNs.  This is likely to
   avoid the nead for ``multipath multiple-as`` on every leaf and to
   simplify spine configuration.  However, even following this numbering
   scheme, the spines will ultimately require ``multipath multiple-as``.

You might notice that because of this design, you will still need extra
configuration to handle the scenario where a prefix is received from
multiple switches.  To work around this, use the
``set protocols bgp group <name> multipath multiple-as`` BGP
configuration.  The biggest difference between this an the requirement
for ADD-PATH in an :ref:`ibgp` is that ADD-PATH is a feature negotiated
between peers, whereas ``multipath multiple-as`` is not.  This results
in less complexity and fewer places for things to go wrong.  It also
increases vendor and platform interoperability since ADD-PATH is not
guaranteed to be supported on a given platform or vendor, but even
without ``multipath multiple-as``, the fabric will still function
(suboptimally).  Additionally, if the spine switches are given the same
ASN instead of a unique ASN per spine switch, the number of places that
require ``multipath multiple-as`` might be reduced depending on your
design and requirements.

.. note::
   ``multipath multiple-as`` is recommended on all nodes.  You *can* get
   away with only deploying it in certain places, but that doesn't mean
   you should.  One of the benefits of deploying an IP fabric is
   reproducibility, and when you start tailoring to such a degree, it
   increases the cognitive load on engineers supporting the fabric
   because they can no longer assume similar behavior amongst nodes.

.. _ip-fabric-scaling:

IP Fabric Scaling
-----------------

The scalability of an IP fabric is largely limited by three things:

* the acceptable oversubscription ratio
* the number of uplinks available per leaf per pod
* the number of ports per spine per pod

The acceptable oversubscription ratio can determine both how many
servers you attach to a leaf and how many spines you need to have, both
of which influence and are influenced by your required speeds downstream
toward servers.  For example, assume you have a 48x10G switch with
6x40G uplinks.  This gives you an oversubscription ratio of 480G:240G,
or 2:1, if you have six spine switches.  However, perhaps it's
unacceptable to have a 2:1 oversubscription ratio.  Maybe you require no
oversubscription.  In this case, you can either select a leaf switch
with more 40G uplinks (and add more spine swithces), or you can decide
that you will not attach any servers to half of the 10G ports.

.. note::
   You can get clever and, if your switch supports it, break out all of
   the 40G ports to 10G ports.  Then use only 10G spines.  Split your
   total 10G ports in half; this number is the number of spines you
   need.  For example, given the same leaf port density above and
   breaking out the 40G ports, you would have 72x10G interfaces.
   Dividing this by two, there are 36 ports downstream toward servers
   and 36 ports upstream toward spines.  This means that you need either
   36 spines *or* multiple ports stacked on spines, perhaps on a
   chassis-based spine such as an MX240.  The end result is that you are
   "wasting" 12x10G ports compared to the 2:1 oversubscription model,
   and you likely need more or larger spines.  In reality, 36 server
   ports in a 48U rack is probably the most (or close to the most)
   you'll get anyway.  All of this said, though, for the purposes of
   this exam, it's likely best to stick with the number of "downstream"
   and "upstream" ports as noted by the difference in port speeds
   (i.e., 10G vs. 40G or 40G vs 100G).

.. _best-practices:

IP Fabric Best Practices
------------------------

There is one critical consideration to make when selecting links between
spines and leafs: bandwdith.  If you go the :ref:`ibgp` route (and you
use OSPF or use different metrics for different bandwidths in IS-IS),
your ECMP will be affected if you have mixed uplink bandwidth from your
leafs (such as 10G and 40G).  The result is that you will have some
unutilized links (except in failure scenarios).

However, with eBGP, link bandwidth is not considered for path
calculation.  If your design uses different bandwidth links, this might
initially seem like a good thing because it results in all links being
utilized.  However, they are not intelligently utilized.  You can easily
exceed the utilization of the lower capacity links, resulting in either
service degradation or complete outage conditions (depending on your
SLAs).

For this reason, in either design, it is critical to ensure that all
paths to a given destination from all possible ingress points have the
same total link bandwidth.  This makes managing oversubscription and
scaling much easier.

All swithces at a given stage (spine, leaf, etc.) should be of the same
model.  This isn't strictly required so long as they can all support the
same features, but if you choose to use different switches, you will be
limited by the smallest number of ports available.  Another
consideration is that some switches may hash traffic differently than
others, leading to unpredictable load sharing characteristics.  In other
words, it's okay if your spines and leafs are different models, but all
of your spines should be the same model, and all of your leafs should be
the same model.

.. note::
   *Technically* you aren't limited by the number of ports.  However,
   this section is all about best practices.  So, in the spirit of best
   practices, don't try to mix and match models in the same pod.

If you have a use case for different spine switches in different pods,
then you can use different spine switches in different pods.  An example
of this might be for "bug diversity."  In other words, you don't want
all of your global data centers to be hit by the same platform/OS bug at
the same time, so you might deploy different vendors or platforms in
each fabric pod.  However, inside of any given pod, you should still use
the same model switch.

When connecting leaf switches to spine switches, every leaf should be
connected to every spine.  Again, you can get away with not doing this,
but to do so is to invite heartache.  If you're thinking of doing it for
scaling reasons, consider implementing a 5-stage IP fabric instead.
This brings some different complexity (not covered here), but it also
brings easier and greater scalability without the risks of
unintentionally oversubscribing or modifying the predictability of some
of your fabric switches but not others.

Configuration
-------------

TODO: Add configuration examples for an IGP with iBGP, eBGP with iBGP,
      and straight eBGP.

.. rubric:: Footnotes

.. [#f1] `Juniper QFX5100 Series <https://www.amazon.com/Juniper-QFX5100-Comprehensive-Building-Next-Generation/dp/1491949570/>`_
.. [#f2] `RFC7938: Use of BGP in Large-Scale Data Centers, Section 5.2: EBGP Configuration for Clos Topology <https://tools.ietf.org/html/rfc7938#section-5.2>`_
.. [#f3] `BGP in the Data Center, Chapter 2, ASN Numbering Model <https://learning.oreilly.com/library/view/bgp-in-the/9781491983416/>`_
