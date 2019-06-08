VXLAN
=====

This blueprint item primarily covers the following topics:

* L2VPN Control Planes
* :ref:`multicast-control-plane`
* :ref:`mcast-data-plane`

.. note::
   Although the VXLAN section of the blueprint indicates L2VPN Control
   Planes, they are not covered here; instead, they are covered on the
   :ref:`vxlan-evpn` page.  I'm unaware of a different L2VPN control
   plane that uses VXLAN for encapsulation; perhaps the blueprint means
   MPLS and/or GRE L2VPNs, but that isn't clear since the item is listed
   under VXLAN.

Additionally, this page covers a brief introduction to VXLAN and why it
exists in the :ref:`introduction-to-vxlan` section.

Finally, because I'm not quite sure where in the blueprint some items
might (or might not) fall, the following sections are written to
describe platform-dependent concepts:

* :ref:`vxlan-gateways`
* :ref:`hardware-positioning`
* :ref:`asymmetric-vs-symmetric-irb`
* :ref:`edge-vs-central-irb`


.. _introduction-to-vxlan:

Introduction to VXLAN
---------------------

Modern data centers require greater scale and security than in years
past.  Traditionally, operators have dealt with spanning tree in the
data center.  While spanning tree itself is not a terrible technology
and has its uses, it does result in unused links, which means network
architects and operators needed to vastly overprovision their network
links in order to have enough bandwidth available to avoid congestion.
This may have come in the form of using 40G links where 10G links would
have otherwise been enough or in the form of using multiple ports in
a LAG.  Both solutions are expensive and can have disastrous failover
consequences, such as a LAG member failing and resulting in insufficient
bandwidth on the active path (degredation of service) or link failures
causing TCNs to be genereated (brief outages as MAC tables are flushed
throughout the network).  Additionally, the scale of every switch in the
data center must also account for the total possible number of MAC
bindings, ARP bindings, and IP addresses across all devices in the
broadcast domain, which may result in purchasing more expensive hardware
than might otherwise be required.

Layer 3 Fabrics and Layer 2 L2VPNs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

One solution to the above problem is :ref:`layer-3-fabrics`; however, a
purely layer 3 fabric introduces its own issues: complexity in the form
of requiring rack awareness; IP planning difficulties; and an inability
to support highly available components that require layer 2 adjacency,
such as clustered firewalls, load balancers, and VRRP-based applications
such as MySQL with ``keepalived`` (which uses VRRP, a protocol that
communicates to the ``224.0.0.18`` multicast group, which is link-local
and not routable).

In order to solve the problems that an IP fabric introduces, a layer 2
overlay can be used.  This is something that's been done in the service
provider realm for several years in the forms of L2VPN/Pseudowires and
VPLS.  These technologies use MPLS to transport layer 2 frames across a
network without requiring the devices in the middle to know the source
and destination MAC addresses, ARP bindings, etc.  However, devices in
the data center traditionally may not have MPLS functionality all the
way to the server point of attachment, and MPLS features are frequently
expensive, so a different way was devised.

.. note::
   Cost isn't the only reason VXLAN was created.  Complexity is another;
   MPLS requires additional protocols and requires that every device
   support it end-to-end; VXLAN does not.  With VXLAN, only the ingress
   and egress devices need to know how to deal with VXLAN; every other
   device in the middle just sees an IP packet.  Additionally, VXLAN
   requires protocols that are frequently used anyway: either a
   multicast routing protocol or BGP.

Encapsulation
^^^^^^^^^^^^^

VXLAN transports layer 2 frames by encapsulating them into an IP packet
with a UDP header.  With VXLAN, an operator maps a VLAN ID to a VNI.
Recall that VLAN IDs are 12 bits in length and can thus support up to
4,096 VLANs.  VXLAN VNIs (Virtual Network Identifiers), on the other
hand, are 24 bits in length and can support up to approximately 16
million unique IDs.  Ultimately, with enough planning, this means that
your tenant scale is now limited to ~4,096 per switch and 16 million
across the entire footprint.

.. _multicast-control-plane:

Multicast Control Plane
-----------------------

Now that we know a little bit about the motivation of VXLAN, we can look
at the control plane protocols that support it.  A key requirement of a
layer 2 overlay (or VPN) is the ability to transport BUM traffic.  With
VXLAN, there are two primary ways to accomplish this: multicast and
ingress (or head-end) replication.  This page covers multicast, while
the :ref:`vxlan-evpn` page covers ingress replication.

PIM
^^^

The multicast control plane for VXLAN exists primary to support the
:ref:`mcast-data-plane`, covered later.  The only way to use multicast
for BUM traffic is to run PIM in your fabric.  You associate each VNI
with a particular multicast group.  This is because when a segment needs
to send a BUM packet, it must be delivered to all interested receivers.
For this reason, the same VNI must be associated with the same group
on all VTEPs.  Eventually, with enough VNIs, you may run into issues
with scaling the number of multicast groups.  You will start mapping
multiple VNIs to a single multicast group, which will result in
inefficient forwarding of BUM traffic to uninterested VTEPs.

The best way to deploy an RP is to use :ref:`anycast-rp`.  You use
PIM-SM and will need reachability via some IGP.  The RP should also be
configured on spines, not leafs.  There are many options for configuring
RP selection, such as static, bootstrap RP, or auto RP.  For the sake of
simplicity, when combined with :ref:`anycast-rp`, a static configuration
is likely the easiest option.

Note that the QFX does not support PIM BiDir [#f4]_.

.. _anycast-rp:

Anycast RP
^^^^^^^^^^

Anycast RP uses the same IP address for the RP on multiple devices.
Anycast RP can be configured either with or without MSDP; for the sake
of simplicity (and assuming this exam isn't focusing heavily on
multicast), we'll only examine the design without MSDP.

When using Anycast RP, you must configure at least two loopback IP
addresses: a unique IP per spine and a shared IP per spine.  The shared
IP per spine is the Anycast IP, and the unique IP is used as the router
ID and so that the routers can sync their multicast states.  When
configuring the shared anycast IP, you have two options: you can either
configure the unique IP as the ``primary`` IP; or you can configure the
anycast shared IP under a different unit.

You must configure an ``rp-set`` for ``pim-anycast`` that includes all
other Anycast RP members; the IP address used when defining the other
members should be the unique IP address of the spine.

.. note::
   Instead of configuring an ``rp-set`` with each spine's unique IP
   address, you can use MSDP.  However, that is out of scope for this
   guide as it seems unlikely (though not impossible) to appear on the
   exam.  For completeness, you should read the
   `Example: Configuring Multiple RPs in a Domain with Anycast RP <https://www.juniper.net/documentation/en_US/junos/topics/topic-map/mcast-pim-anycast-rp.html>`_
   configuration guide from Juniper.  Additionally, the configuration of
   MSDP is likely more complicated than configuring an ``rp-set`` given
   the scale.


.. _mcast-data-plane:

Data Plane
----------

This section describes the VXLAN data plane for two different
operations: :ref:`dp-known-unicast` and :ref:`dp-bum`.  It also contains
a section explaining the default 802.1q stripping behavior and how to
override this in the :ref:`dot1q-stripping` section.

.. _dot1q-stripping:

802.1Q Stripping
^^^^^^^^^^^^^^^^

It's worth noting that the default behavior of a VTEP is to strip the
VLAN ID before encapsulating a frame in a VxLAN packet.  The reverse is
also true: if a VxLAN packet is decapsulated and a VLAN ID is present,
the frame is discarded.  This behavior can be modified on both the QFX
and MX platforms.

On the MX, both the encapsulating and decapsulating behaviors are
modified at the ``[bridge-domains <name> vxlan]`` hierarchy.  For
example, ``set bridge-domains bd273 vxlan encapsulate-inner-vlan`` will
preserve the inner VLAN ID, and
``set bridge-domains bd273 vxlan decapsulate-accept-inner-vlan`` will
accept decapsulated frames with a VLAN ID present.

On a QFX, the hierarchy level for preserving VLAN IDs when encapsulating
is done at the ``[vlans <name> vxlan]`` level, while accepting
decapsulated frames with a VLAN ID present is done at the
``[protocols l2-learning]`` level.  For example,
``set vlans vlan273 vxlan encapsulate-inner-vlan`` and
``set protocols l2-learning decapsulate-accept-inner-vlan``.

.. note::
   The option is the same between both the MX and the QFX, but where it
   is applied is different.  The MX can perform these actions separately
   on multiple bridge domains, while the QFX applies them at a global
   level.

.. _dp-known-unicast:

Data Plane for Known Unicast Traffic
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

VXLAN traffic is encapsulated and decapsulated by a VTEP.  A VTEP can be
either a hardware (such as a QFX5100) or software (such as Open vSwitch)
device.  This encapsulation consists of a new VXLAN header, a new UDP
header, a new IP header, and a new Ethernet header.  The information for
each header is described in the list below.

.. TODO::
   Write the table instead of a list.

* Ethernet Header: This is a normal Ethernet header; its source MAC will
  be the SMAC of the egress switchport; the destination MAC will be the
  DMAC of the next hop IP address.
* IP Header: The source IP will be the local VTEP; the destination IP
  will be the remote VTEP that contains the remote host of the original
  IP packet.
* UDP Header: The source port is a random port based on a hashing
  algorithm of the original payload headers, and that hashing algorithm
  may depend on the specific hardware platform.  The destination port is
  usually the well-known (registered) VXLAN port of ``4789``, though
  this can be changed on some implementations of VXLAN (especially those
  that are software-based, such as the Linux kernel or Open vSwitch).
* VXLAN Header: This is an 8 byte header that contains the VNI, a 24-bit
  field.  8 bits are used for flags, and the other 32 bits are reserved
  for future use.

The ingress VTEP adds these headers, and the egress VTEP removes them.
Any devices between the VTEPs treat the packet as a normal packet,
forwarding according to that platforms hashing algorithm for the outter
packet.

.. _dp-bum:

Multicast Data Plane for BUM Traffic
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The multicast data plane is simple compared to the
:ref:`multicast-control-plane`.  At a high level, a BUM frame is
encapsulated in a new VXLAN packet, including new layer 2, 3, and 4
headers.  When it arrives on the destination VTEP(s), it is
decapsulated, revealing the original segment.  This is similar to the
operations in the :ref:`dp-known-unicast`.  The biggest difference is
that the destination IP is not that of the destination VTEP but is
instead that of the multicast group associated with the VNI.

.. note::
   In addition to BUM traffic, the multicast topology is used to
   discover remote VTEPs.

When dealing with a software VTEP, an IGMP Join is translated into a PIM
Register by the PIM DR.  These PIM Register messages are unicast to the
RP.  The RP decapsulates the message and forwards it to the destination
VTEP.  At this point, the tree switches from an RPT (``(*,G)`` state) to
an SPT (``(S,G)`` state).

.. note::
   Multicast isn't heavily called out in the JNCIP-DC syllabus [#f5]_,
   so I expect it to be covered very lightly.  There seems to be a
   heavier focus in both documentation and the syllabus on
   :ref:`vxlan-evpn`.  For this reason, these notes do not attempt to be
   an exhaustive multicast reference or even a primer.

.. _vxlan-gateways:

VxLAN L2 and L3 Gateways
------------------------

VxLAN has two types of gateways: Layer 2 and Layer 3.

VxLAN Layer 2 Gateway
^^^^^^^^^^^^^^^^^^^^^

A Layer 2 Gateway is what bridges a VLAN to a VNI (or vice versa).  It
is the stitching point for converting a legacy layer 2 network (a VLAN)
to an overlay layer 2 network (a VxLAN VNI).


VxLAN Layer 3 Gateway
^^^^^^^^^^^^^^^^^^^^^

A VxLAN Layer 3 Gateway routes traffic between two VNIs.  In a Juniper
network, the VxLAN Layer 3 Gateway is frequently a QFX10k or MX Series
device running at the spine layer; in this architecture, your spine
switches must also be VTEPs.  This presents a complexity and scaling
issue.  The :ref:`hardware-positioning` section below discusses where
to place specific Juniper hardware in the network.

.. note::
   VxLAN Layer 3 Gateway is sometimes simply referred to as VxLAN
   routing.  In other materials, you may see it referred to as RIOT
   (Routing In and Out of Tunnels).

.. _hardware-positioning:

Hardware Positioning
--------------------

Hardware positioning depends on the design.  The design depends on
hardware selection.  This cyclical dependency can be difficult to tease
apart.  However, there is a simple rule of thumb:

If you want your leaf/top-of-rack layer to provide VxLAN Layer 3 gateway
services, do not use the following hardware platforms:

- EX4300 (Broadcom Trident 2)
- EX4600 (Broadcom Trident 2)
- QFX5100 (Broadcom Trident 2)
- QFX5200 (Broadcom Tomahawk)

This is because of the ASICs used.  These switches all use either the
Broadcom Trident 2 or Tomahawk chipsets, which do not support the
required functionality in hardware.  If you already have an investment
in these platforms, then it would be best to use them for VxLAN Layer 2
gateway services and implement a spine layer with the QFX10k or MX
Series devices for your VxLAN Layer 3 gateway services.  However, if you
are starting fresh, consider the QFX5110 or QFX10k Series devices for
your leaf/top-of-rack layer as they will allow you to perform VxLAN
Layer 3 gateway services, thus reducing the traffic tromboning for
inter-VxLAN routing in your data center fabric.

.. note::
   There are ways around this with other vendors, but it is unclear if
   Juniper supports these workarounds.

If you want VxLAN Layer 3 gateway services, the following platforms can
be used:

- QFX5110 Series (Broadcom Trident 2+)
- QFX10000 Series (Juniper Q5)
- MX Series (Juniper Trio)

The QFX5110 is based on the Broadcom Trident 2+ and can perform VxLAN
Layer 3 gateway services.  The QFX10000 Series switches run a custom
Juniper ASIC known as the Q5.  This is also capable of performing the
VxLAN Layer 3 gateway function.  The MX Series uses Trio, which is a
custom chipset that is incredibly flexible and can perform the VxLAN
Layer 3 gateway services.

Ultimately, most of these platforms have some limitations to consider
[#f6]_.  A general rule of thumb is to use the Trident 2 and Tomahawk
chipsets for Layer 2 VxLAN and other chipsets for Layer 3 VxLAN
services or to use newer chipsets for every tier.

.. _asymmetric-vs-symmetric-irb:

Asymmetric vs Symmetric IRB
---------------------------

.. note::
   Juniper's original implementation used the :ref:`asymmetric-irb`
   model.  With the QFX10k and MX Series, they have implemented
   :ref:`symmetric-irb`.  See :ref:`hardware-positioning` for
   additional hardware-specific details.

.. _asymmetric-irb:

Asymmetric IRB
^^^^^^^^^^^^^^

Asymmetric IRB performs bridging and routing on the ingress VTEP, but
only briding on the egress VTEP.  When a host wants to send a packet to
a host in a different broadcast domain, it sends the packet with the
destination MAC set to that of its default gateway as normal.  When the
ingress VTEP receives the frame, it performs a route lookup and
encapsulates the frame in a VxLAN header, setting the VNI to that of the
egress VNI.  When the egress VTEP receives the VxLAN packet, it
decapsulates it and bridges it directly onto the destination VLAN (known
by the VLAN-to-VNI mapping).  This happens in the opposite direction as
well.  The end result is that the VNI used when transporting a frame
between two layer 2 domains will always be the egress VNI.

This model suffers a significant scalability penalty because it must
have all VNIs configured even if there is not a host in that segment
attached to the switch.  This is because the ingress node must know
about the egress VNI on the egress VTEP.  However, its configuration
is simpler, and depending on the hardware platform, :ref:`symmetric-irb`
might incur a performance penalty due to requiring one additional lookup
on the egress VTEP compared to the Asymmetric IRB model.

Asymmetric IRB may sometimes be described as ``bridge-route-bridge``.
This refers to the lookups performed when moving traffic between two
layer 2 segments.  The ingress VTEP performs a bridging and routing
operation, while the egress VTEP only performs a bridging operation.

.. _symmetric-irb:

Symmetric IRB
^^^^^^^^^^^^^

With Symmetric IRB, there is a dedicated Layer 3 VNI that is used for
all layer 3 routing between any two layer 2 VNIs for the same tenant.
This results in more configuration for the devices, and it also requires
an additional hardware lookup when compared to :ref:`asymmetric-irb`,
but it is more scalable because it does not require the egress VNI to be
configured on an ingress VTEP if there is not a host attached to that
VNI locally.

Symmetric IRB may sometimes be described as
``bridge-route-route-bridge``.  This refers to the ingress VTEP
performing a briding and routing operation and then the egress VTEP
performing a routing and bridging operation.

Edge vs. Central Routing and Bridging
-------------------------------------

In VxLAN, there are two mechanisms for routing traffic: edge and
central.  These terms refer to how traffic in an overlay is routed.  In
both cases, the IP and MAC address must be the same for active/active
forwarding; however, with :ref:`crb`, you can use active/standby gateway
solutions such as VRRP.

.. _crb:

Central Routing and Bridging
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Central Routing and Bridging refers to doing VxLAN routing on a central
set of devices, such as the spines or a pair of special border leafs.
There can be a scalability and complexity issue if this model is
implemented on spines as it means that all spines must also be VTEPs and
must support advanced VxLAN features.  Bandwidth utilization is also a
concern because if a tenant has multiple VNIs, even if the VMs are
located on the same leaf switch, they must both go up to the spine
switch in order to talk to each other.  When implementing on a dedicated
pair of border leafs, bandwidth utilization becomes an even larger
consideration as traffic must go up to the spines, down to the border
leafs, and back again.  This type of design is reminiscent of some of
the classic traffic tromboning and hairpinning issues.

.. note::
   While this is probably good for a vendor, it may not be great for an
   operator.  It increases operational complexity and the cost of the
   solution.  It may also be a significant waste of bandwidth.

CRB may be the correct design if you need very high ACL scale or when
advanced services (load balancing, NAT, firewalls, etc.) are not native
to your VxLAN overlay.

Edge Routing and Bridging
^^^^^^^^^^^^^^^^^^^^^^^^^

Edge Routing and Bridging may sometimes be called Anycast Gateway or
Distributed Gateway.  In this model, each leaf performs VxLAN routing.
In order to minimize potential disruption, it is imperative that all
VTEPs use the same IP address and MAC address for the IRB interface for
a given Layer 3 Gateway.

.. _configuration:

Configuration
-------------

TODO: Add configuration examples for a VXLAN multicast control plane
using OSPF as the IGP and :ref:`anycast-rp`.

.. rubric:: Footnotes

.. [#f1] `Juniper QFX5100 Series <https://www.amazon.com/Juniper-QFX5100-Comprehensive-Building-Next-Generation/dp/1491949570/>`_
.. [#f2] `RFC7938: Use of BGP in Large-Scale Data Centers, Section 5.2: EBGP Configuration for Clos Topology <https://tools.ietf.org/html/rfc7938#section-5.2>`_
.. [#f3] `BGP in the Data Center, Chapter 2, ASN Numbering Model <https://learning.oreilly.com/library/view/bgp-in-the/9781491983416/>`_
.. [#f4] `Junos Feature Explorer - Bidirectional PIM <https://apps.juniper.net/feature-explorer/feature-info.html?fKey=3786&fn=Bidirectional%20PIM>`_
.. [#f5] `JNCIP-DC Syllabus <https://www.juniper.net/us/en/training/certification/certification-tracks/data-center-track?tab=jncip-dc>`_
.. [#f6] `VXLAN Constraints on QFX Series and EX Series Switches <https://www.juniper.net/documentation/en_US/junos/topics/concept/vxlan-constraints-qfx-series.html>`_
