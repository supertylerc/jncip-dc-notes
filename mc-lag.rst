Multi-Chassis LAG (MC-LAG)
==========================

Multi-Chassis LAG is a technology that allows two independent systems
to present themselves as a single system while still operating
indepedently.  This is in contrast to Virtual Chassis, which makes
multiple independent systems operate as a single system.  At the highest
level, MC-LAG works by forcing the two upstream devices to use the same
LACP System ID, which makes the downstream device think that the
upstream devices are just one device.

Before diving into the specifics of an MC-LAG configuration, it is
critical to know which settings *must match* and which settings *must be
unique* between peers.  The following section describes which must match
and which must be unique [#f1]_.

Must match:

* LACP System ID
* LACP Admin Key
* MCAE ID
* MCAE Mode
* VLANs
* Redundancy Group ID [#f2]_
* Service ID [#f2]_

Must be unique:

* MCAE Chassis ID
* MCAE Status Control
* Local ICCP IP
* Peer ICCP IP
* MC-LAG Protection

Finally, a diagram is worth a thousand words.  If you have the Juniper
MX Series book from O'Reilly [#f4]_, I can highly recommend Figure 9-4
as a reference.  I won't reproduce it here because that would be
incredibly rude and inconsiderate, so please pick up that book if you
can.  Chapter 9, MC-LAG, is definitely worth it!  Just in case you have
a Safari subscription,
`here's a link straight to the diagram <https://learning.oreilly.com/library/view/juniper-mx-series/9781491932711/ch09.html#iccp_hierarchy-id00050>`_.
But again, definitely read the entire chapter.  It's absolutely worth
it.

.. note::
   I'm hoping the authors don't mind me including a link directly to the
   diagram in the Safari Online book.  But if you're one of the authors
   or the publisher and want that removed, *please* reach out to me and
   let me know and I will gladly remove it.


Terminology
-----------

This section explains some of the terminology and configuration elements
listed above. [#f2]_

.. _service-id:

Service ID
^^^^^^^^^^

The Service ID must match between two ICCP peers.  The Service ID exists
for use cases where MC-LAG is used in more than one routing instance.
This ID is global.

.. _mcae-redundancy-group:

Redundancy Group ID
^^^^^^^^^^^^^^^^^^^

The Redundancy Group ID must match between two ICCP peers.  It contains
a grouping of MC-LAG bundles and their associated VLANs.  It is useful
because it allows the ICCP peers to send an update once instead of
sending an update for each MC-LAG.  For example, when a MAC address is
learned, the MAC only needs to be sent to the ICCP peer one time for
that redundancy group instead of multiple times for each MC-LAG in the
group.  This ID is not required to be global, but can encompass one or
more MC-LAG bundles.

.. note::
   In vQFX 18.1R1.9, on which this document is based, there can only be
   one Redundancy Group ID configured.  Although a list is supported,
   the ``commit check`` will fail with an error if more than one is
   provided.  This is probably because only one bridge domain is
   supported, and a Redundancy Group is a broadcast domain.  In the MX
   router, multiple Redundancy Group IDs are supported.

.. _mcae-id:

MCAE ID
^^^^^^^

The Multi-Chassis Aggregated Ethernet Identifier must match between
peers.  This number must be unique per MC-LAG.

.. _mcae-chassis-id:

MCAE Chassis ID
^^^^^^^^^^^^^^^

The MCAE Chassis ID uniquely identifies a chassis.  Therefore, this ID
must be unique between ICCP peers.

.. _lacp-system-id:

LACP System ID
^^^^^^^^^^^^^^

This ID is used by LACP to identify the system to which a remote
belongs.  This ID must match between peers.  It is used to "trick" the
remote LACP peer into thinking it is talking to only one system.

.. _lacp-admin-key:

LACP Admin Key
^^^^^^^^^^^^^^

This is used in conjunction with the LACP System ID to uniquely identify
an LACP peer.  It must match between peers.

.. _mcae-mode:

MCAE Mode
^^^^^^^^^

``active-active`` or ``active-standby``.  Must match between peers.

.. note::
   Only ``active-active`` is supported on the QFX and EX Series.
   However, both ``active-active`` and ``active-standby`` are supported
   on the MX series with MPCs.  ``active-active`` with a DPC on an MX
   is not supported; you must use ``active-standby`` in those scenarios.
   [#f3]_

.. _status-control:

Status Control
^^^^^^^^^^^^^^

Controls whether the node will be the active or standby node if ICCP
fails.  Only two options exist: ``active`` or ``standby``.  One node
must be ``active`` and the other must be ``standby``.  The ``standby``
node will change its :ref:`lacp-system-id`.

.. _chassis-protection:

MC-LAG Protection
^^^^^^^^^^^^^^^^^

Multi-chassis Link Protection ensures the appropriate behavior of the
node configured as :ref:`status-control` ``standby`` when the ICL goes
down.  For example, if the ICL goes down, should the ``standby`` node
change its :ref:`lacp-system-id`, thereby taking its MC-LAG link down,
or should it leave it as-is, making it actively receive traffic?  Link
Protection uses an out-of-band mechanism to determine if the remote ICCP
peer is still up or not.  If the ICL is down but the remote ICCP peer is
still up, then the ``standby`` node will change its
:ref:`lacp-system-id`.  However, if the ICL is down and the remote ICCP
peer is also down, then the ``standby`` node will *not* change its
:ref:`lacp-system-id`.  This will ensure that there is no outage.

Guidelines
----------

The follow sections describe high-level, general guidelines when
deploying MC-LAG.  None of these recommendations are hard-and-fast
rules, but they should be taken into consideration with any MC-LAG
deployment.

Inter-Chassis Link Redundancy
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Although not required, it is strongly recommended that the ICL consist
of at least two links.  This ICL link needs to have VLANs trunked across
it.  It needs to have the downstream VLANs trunked plus the ICCP VLAN.
The reason for trunking the downstream VLANs is in case one of the
MC-LAG links goes down and traffic needs to go between the switches.

Compensating for Lack of LACP support
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Generally speaking, your downstream LACP bundle will be a
single-interface LAG per upstream device.  If the downstream device does
not support LACP, you can use the ``force-up`` flag.  However, if the
downstream device *does* support LACP, it is strongly recommended to use
LACP and leave the ``force-up`` option off.

.. _layer-3-connectivity:

Layer 3 Connectivity
^^^^^^^^^^^^^^^^^^^^

For simple layer 3 connectivity, such as when the downstream device is a
server, both of the upstream MC-LAG peers can have their gateways
configured with the same IP address when ``mcae-mac-synchronization`` is
enabled on the VLAN.  Unlike VRRP, this will keep traffic local to the
switch that receives the packet.  This works by allowing one upstream
switch to respond with the peer switch's MAC address.  The end result is
that each upstream switch treats a packet as if it is its own.
``mcae-mac-synchronization`` in this scenario is required because,
without it, ARP requests are not sniffed or replicated by the peers.

.. note::
   DHCP Relay is not supported with ``mcae-mac-synchronization``.  If
   a DHCP Relay is required, you must use VRRP.

When routing protocols are required with an MC-LAG,
``mcae-mac-synchronization`` is no longer an option.  This is because
the MAC synchronization option works similarly to an anycast service,
but routing protocols require 1:1 direct relationships.  For this
reason, when protocol adjacency is required (such as OSPF between the
aggregation and core layers), VRRP is required.  In these instances, the
devices should peer to the VRRP VIP, not the real IP.  To compensate for
potential issues, a static ARP address for the *remote* peer's IRB MAC
and real IP should be configured.

.. _stp:

Spanning Tree Protocol
^^^^^^^^^^^^^^^^^^^^^^

Although the goal of MC-LAG is to remove the need for a Spanning Tree
Protocol, it is highly recommended that STP is enabled to prevent loops
caused by miswiring as well as to prevent unintentional propagation of
BPDUs.

When configuring STP, disable STP on the ICL.  This is because STP could
cause the traffic on the ICL to be blocked, thereby breaking the
MC-LAGs.  Configure all MC-LAG interfaces as ``edge``.  A downstream
device should not be able to cause a loop in a properly designed
network.  Turn on ``bpdu-block-on-edge``.  This is to prevent malicious
or unintentional BPDU propagation.

.. note::
   Do *not* configure MSTP or VSTP.  This can cause loops when not
   configured appropriately on all devices, including downstream
   devices. [#f3]_

Configuration
-------------

In this example, there are four vQFX switches: vQFX-1 through vQFX-4.
vQFX-1 and vQFX-2 are our MC-LAG head-end devices.  Their ICL is
``ae0``, which consists of members ``xe-0/0/0`` and ``xe-0/0/1``.

They run an MC-LAG down to vQFX-3 on ``ae1`` and to vQFX-4 on ``ae2``.
``ae1`` consists of ``xe-0/0/2`` on vQFX-1 and ``xe-0/0/4`` on vQFX-2.
``ae2`` is made up of ``xe-0/0/3`` on vQFX-1 and ``xe-0/0/5`` on vQFX-2.
The interface numbers are the same on vQFX-3 and vQFX-4 as their
upstream devices with the exception of the bundle interface.  On vQFX-3
and vQFX-4, that is ``ae0``.  You can see this below in the
``show lldp neighbors`` output for each device:

.. literalinclude:: configs/mclag/lldp.output
    :language: perl
    :emphasize-lines: 3-6,11-14,20-21,27-28

The MC-LAG to vQFX-3 provides normal layer 3 gateway services.  We use
MAC address synchronization here.  The MC-LAG toward vQFX-4, however,
runs OSPF.  For this, we remove MAC address synchronization and
implement VRRP with static ARP bindings.  See
:ref:`layer-3-connectivity` for more details about this.

The final test will be pinging between vQFX-3 and vQFX-4's ``ae0``
interfaces.

.. note::
   I don't have Visio or Omnigraffle, and I found making diagrams in
   anything else highly frustrating.  So for now, there are no diagrams.
   :(  However, if you'd like to contribute some, they would be greatly
   appreciated!

The very first thing to do with any LAG in Junos is to set the number of
LAG interfaces:

.. literalinclude:: configs/mclag/qfx1.cfg
    :language: perl
    :lines: 1-8
    :emphasize-lines: 1

.. literalinclude:: configs/mclag/qfx2.cfg
    :language: perl
    :lines: 1-8
    :emphasize-lines: 1

.. literalinclude:: configs/mclag/qfx3.cfg
    :language: perl
    :lines: 1-8
    :emphasize-lines: 1

.. literalinclude:: configs/mclag/qfx4.cfg
    :language: perl
    :lines: 1-8
    :emphasize-lines: 1

Next, we configure the :ref:`service-id` on the upstream devices:

.. literalinclude:: configs/mclag/qfx1.cfg
    :language: perl
    :lines: 1,169-171
    :emphasize-lines: 1

.. literalinclude:: configs/mclag/qfx2.cfg
    :language: perl
    :lines: 1,169-171
    :emphasize-lines: 1

Next, we'll configure the ICL.  For redundancy, we'll configure the ICL
as an LACP bundle:

.. literalinclude:: configs/mclag/qfx1.cfg
    :language: perl
    :lines: 1,9-19,30-45,122
    :emphasize-lines: 1

.. literalinclude:: configs/mclag/qfx2.cfg
    :language: perl
    :lines: 1,9-19,30-45,122
    :emphasize-lines: 1

.. note::
   If you have a device with different line cards/slots/ASICs, consider
   spreading your bundle members across them for greater resiliency.

Now that the ICL has its layer 1 and layer 2 configuration done, we need
to ensure it can route packets for ICCP.  Since ICCP only requires
TCP/IP connectivity to establish, this could be done between loopback
interfaces.  However, for the example, we'll just use an IRB interface.

.. literalinclude:: configs/mclag/qfx1.cfg
    :language: perl
    :lines: 1,9,98-103,121-122,172-176,186
    :emphasize-lines: 1

.. literalinclude:: configs/mclag/qfx2.cfg
    :language: perl
    :lines: 1,9,98-103,121-122,172-176,186
    :emphasize-lines: 1

Next, we need to configure ICCP:

.. literalinclude:: configs/mclag/qfx1.cfg
    :language: perl
    :lines: 1,131,140-152,168
    :emphasize-lines: 1

.. literalinclude:: configs/mclag/qfx2.cfg
    :language: perl
    :lines: 1,131,140-152,168
    :emphasize-lines: 1

Note that we're configuring BFD for faster failure detection in this
example.  By default, this will create a new BFD session that runs on
the control plane.  However, if your platform supports it and you are
not running ICCP via loopback interfaces (and ICCP is using IPs that are
directly connected), you can push this down to the PFE with the
``set protocols iccp peer <ip> liveness-detection single-hop`` command.

.. note::
   In production, a best practice would be to configure ICCP between the
   loopback interfaces to ensure the ICCP session stays up, even if the
   ICL is down.

At this point, everything has been done such that ICCP should come up.
This can be verified with the ``show iccp status`` command:

.. literalinclude:: configs/mclag/iccp.output
    :language: perl
    :lines: 1-37
    :emphasize-lines: 3-7,22-26

Before going on, we have two minor things to finish up: configuring
:ref:`chassis-protection` and configuring :ref:`stp`:

.. literalinclude:: configs/mclag/qfx1.cfg
    :language: perl
    :lines: 1,123-127,131,153-156,163-168
    :emphasize-lines: 1

.. literalinclude:: configs/mclag/qfx2.cfg
    :language: perl
    :lines: 1,123-127,131,153-156,163-168
    :emphasize-lines: 1

All that's left to finish our MC-LAG configuration is to start bringing
up MCAEs!  First, we'll work on the MC-LAG toward vQFX-3.

.. literalinclude:: configs/mclag/qfx1.cfg
    :language: perl
    :lines: 1,9,20-24,46-71,98,104-108,122,131,153,157-159,168,172,177-181,186
    :emphasize-lines: 1,13-14,16-23,51

.. literalinclude:: configs/mclag/qfx2.cfg
    :language: perl
    :lines: 1,9,20-24,46-71,98,104-108,122,131,153,157-159,168,172,177-181,186
    :emphasize-lines: 1,13-14,16-23,51

The lines highlighted are specific to MC-LAG; everything else is just
normal LACP configuration.  Note that on both vQFX-1 and vQFX-2 the
:ref:`lacp-system-id`, :ref:`lacp-admin-key`, :ref:`mcae-id`,
:ref:`mcae-redundancy-group`, and :ref:`mcae-mode` are all the same.

However, the :ref:`mcae-chassis-id` and :ref:`status-control` are unique
between the two devices.

Next we'll configure vQFX-3, which is just standard LACP configuration:

.. literalinclude:: configs/mclag/qfx3.cfg
    :language: perl
    :lines: 1,9-39
    :emphasize-lines: 1

We add a static default route so that we can ping vQFX-4 later once its
configuration is complete.  But first, let's make sure we can ping our
gateway!

.. literalinclude:: configs/mclag/ping.output
    :language: perl
    :lines: 1-8
    :emphasize-lines: 5

Success!  Let's move on to configuring the MCAE toward vQFX-4, which is
slightly more complicated due to running OSPF.  We'll split up the layer
2 configuation and the layer 3 configuration to make it a little easier
to digest.

First, let's configure the upstream devices:

.. literalinclude:: configs/mclag/qfx1.cfg
    :language: perl
    :lines: 1,9,25-29,72-97,122,131,153,160-162,168,172,182-186
    :emphasize-lines: 1,13-14,16-23

.. literalinclude:: configs/mclag/qfx2.cfg
    :language: perl
    :lines: 1,9,25-29,72-97,122,131,153,160-162,168,172,182-186
    :emphasize-lines: 1,13-14,16-23

The MC-LAG-specific configurations are highlighted above.

.. note::
   Notice in this example that we did not configure
   ``mcae-mac-synchronization`` on the VLAN.  This is because we will be
   using VRRP due to the OSPF requirement, and these two configurations
   are mutually exclusive on the QFX series switches.

Now let's examine the layer 3 configuration on vQFX-1 and vQFX-2:

.. literalinclude:: configs/mclag/qfx1.cfg
    :language: perl
    :lines: 1,9,98,109-122,128-139,168
    :emphasize-lines: 1,7

.. literalinclude:: configs/mclag/qfx2.cfg
    :language: perl
    :lines: 1,9,98,109-122,128-139,168
    :emphasize-lines: 1,7

The only line that is different compared to standard layer 3
configuration is the static ARP entry.  Recall from
:ref:`layer-3-connectivity` that we need a static ARP entry pointing to
the remote device's IRB MAC address via the ICL.  That's all this
configuration line does: create a static ARP entry for the real IP of
the remote switch with its IRB MAC via the ICL.

We can now examine vQFX-4's configuration:

.. literalinclude:: configs/mclag/qfx4.cfg
    :language: perl
    :lines: 1,9-43
    :emphasize-lines: 1

This is just standard configuration.  No special tricks required!  Let's
check OSPF:

.. literalinclude:: configs/mclag/ospf.output
    :language: perl
    :lines: 1-20
    :emphasize-lines: 3-4,10-11,17-18

Finally, let's ensure we can ping between vQFX-3 and vQFX-4:

.. literalinclude:: configs/mclag/ping.output
    :language: perl
    :lines: 10-26
    :emphasize-lines: 5,14

And that's it!  MC-LAG configuration for simple gateway and advanced
layer 3 routing is working.

Conclusion
----------

We've brushed the surface of MC-LAG, hopefully enough for the JNCIP-DC.
For more detailed information, check out Juniper MX Series, Second
Edition [#f4]_.

.. rubric:: Footnotes

.. [#f1] `Juniper Ambassador's Cookbook 2019, Recipe #5 <https://www.juniper.net/us/en/training/jnbooks/day-one/ambassadors-cookbook-2019/index.page>`_
.. [#f2] `Juniper MX Series, Chapter 9, ICCP Hierarchy Section <https://www.amazon.ca/Juniper-MX-Comprehensive-Guide-Technologies/dp/1491932724/>`_
.. [#f3] `Understanding Multichassis Link Aggregation Groups <https://www.juniper.net/documentation/en_US/junos/topics/concept/mc-lag-feature-summary-best-practices.html>`_
.. [#f4] `Juniper MX Series, Second Edition <https://www.amazon.com/Juniper-MX-Comprehensive-Guide-Technologies/dp/1491932724/>`_
