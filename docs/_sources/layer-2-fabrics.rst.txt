Layer 2 Fabrics
===============

This blueprint item primarily covers the following topics:

* :ref:`vc`
* :ref:`vcf`

.. note::
   Both :ref:`vc` and :ref:`vcf` are hardware-based architectures.
   Unfortunately, I do not have access to real hardware; all of my
   labbing is based on the vQFX0000.  This means that although there
   may be configurations presented, I don't currently have a way of
   validating.  If you have access to physical gear and can validate
   the configurations (or present more interesting
   topologies/configurations), I would love to see them contributed!


.. _vc:

Virtual Chassis
---------------

The EX4300, QFX3500, QFX3600, and QFX5100 can form a mixed mode Virtual
Chassis.  If you are familiar with mixed mode Virtual Chassis from the
Enterprise track (EX4200/EX4500/EX4550), the concept is very similar.
Up to 10 switches are supported in a stack, although some switches, such
as the QFX5100-96S, may not be supported.

The first step in creating a mixed mode Virtual Chassis is to tell each
individual switch that it will be participating in a mixed mode VC with
the ``request virtual-chassis mode mixed reboot`` command.  However,
when building a new stack, the
``request virtual-chassis mode mixed all-members reboot`` command can be
used to set all members in the stack to mixed mode at the same time.

.. note::
   When operating in a mixed mode Virtual Chassis, the scaling numbers
   are reduced to the lowest common denominator.  This severely limits
   the scalability of a deployment.  The lowest common denominator is
   the lowest scaling factor of the smallest possible PFE.  This means
   that if you have a mixed Virtual Chassis of QFX3500 and QFX5100, even
   if there is no EX4300, each device will still be limited to the
   maximum scale of an EX4300.

The benefits of a mixed mode Virtual Chassis are the same as those of a
regular Virtual Chassis:

* Redundant Routing Engines
* NSR and NSB
* One control plane for multiple data planes
* Potential elimination of xSTP

By default, the 40G QSFP+ ports on an EX4300 are enabled for Virtual
Chassis; however, on the QFX5100, these ports are disabled for Virtual
Chassis.  When a mixed mode VC contains QFX5100 switches, only the
QFX5100 can become an RE.  As with many protocols consisting of primary
and secondary nodes, the VC mastership process follows an election
process.  The first tie-breaker is priority, which is 128 by default.
Higher is better.  If the priority values are the same, the next factor
to consider is which node was the master prior to a reboot.  Next, the
member with the highest uptime; however, the difference in uptime must
be more than 60 seconds.  Finally, all else being equal (and difference
in uptime being less than 60 seconds), the member with the *lowest* MAC
address will be elected as the master.  The backup is elected according
to the same criteria.

When implementing Virtual Chassis, you can use the
``virtual-chassis auto-sw-upgrade`` configuration to automatically
upgrade members with the ``LC (Line Card)`` state when their software
version does not match that of the Master RE.  Additionally, Split
Detection can be disabled with the
``virtual-chassis no-split-detection`` configurtation.  However, this
should only be done when there are only two members in the Virtual
Chassis.

On a QFX5100, you will need to set ports as Virtual Chassis Ports with
the ``request virtual-chassis vc-port set pic-slot 0 port 48``
operational command.

Virtual Chassis supports a special deviation of ISSU called NSSU:
Non-Stop Software Upgrade.  For NSSU to work, the physical topology must
be a ring -- it cannot be a braid.  The master and backup must be
adjacent; this means that the roles of each switch must be
deterministic.  For this reason, only pre-provisioned Virtual Chassis is
supported.  Additionally, both NSR and GRES must be configured; NSB is
optional.  To initiate an NSSU, issue the
``request system software nonstop-upgrade [<path_platform1> <path_platform2>]``
command.

.. _vcf:

Virtual Chassis Fabric
----------------------

Virtual Chassis Fabric is an extension of Virtual Chassis.  It works
with QFX3500, QFX3600, QFX5100, and EX4300 series switches.
New switches added to a VCF are automatically discovered and brought
online.

.. note::
   The node limit is unclear.  In Chapter 5 of the O'Reilly QFX5100
   Series book [#f1]_, a passage indicates that the maximum number of
   switches is 32; however, recent Juniper documentation publications
   [#f2]_ indicate that the limit is 20.  Because the documentation is
   more recent than the published book, even though there is no
   confirmed and published errata [#f3]_, readers should assume a limit
   of 20 nodes.

Like :ref:`vc`, VCF uses IS-IS between switches.  The links between
switches, however, come up as "Smart Trunks."  This is part of what
enables VCF to perform unequal cost multipath load balancing in certain
designs and failure scenarios.  The other technology that enables
unueqal cost multipath is Adaptive Load Balancing.  ALB hashes TCP
flowlets to different links.

These flowlets are tracked in a hash bucket table.  This table can hold
hundreds of thousands of entries -- enough to prevent "elephant flows"
from overloading a given link.  When the flowlet egresses the switch,
the hash table is updated with a timestamp and the link via which it
egressed.  When a new packet for the same flowlet egresses, it is
checked against an expiration or inactivity timer.  If the time since
the last packet was seen is greater than the inactivity timer, then the
flowlet is hashed to a new uplink.  The egress link selection is also
based on a moving average of the load and queue depth on each interface.

ALB is disabled by default; to enable it in a VCF, use the
``set fabric-load-balance flowlet`` configuration command.

Not all switches can be spine switches, but all switches can be leaf
switches.  A general rule of thumb is that a fiber-based QFX5100 can be
a leaf switch or a spine switch; any other switch can only be a leaf
switch.

Provisioning Options
^^^^^^^^^^^^^^^^^^^^

When configuring a VCF, you have three options: auto-provisioned,
pre-provisioned, and non-provisioned.  Each has its own benefits and
drawbacks; auto-provisioned is less secure, while the non-provisioned
mode is more configuration-intensive and less predictable.

With an auto-provisioned VCF, you must specify the role and serial
number for each spine switch; the leaf switches are automatically added.
The Virtual Chassis Ports are automatically discovered and added.

With a pre-provisioned VCF, you specify each spine *and* leaf member.
Virtual Chassis Ports are also automatically discovered and added.
Configuring a VCF in this mode is the same as configuring a :ref:`vc`
in pre-provisioned mode.

.. note::
   If you do not want links between switches to be converted to VCPs
   automatically, delete the LLDP configuration before powering on
   additional switches.

.. note::
   If you're using a mixed mode :ref:`vcf`, you need to disable the
   VCPs on any EX4300 switch in order for the VCPs to autonegotiate
   successfully.  Converting VCPs to network interfaces is covered
   in the :ref:`data-plane` section.

The non-provisioned mode is similar to the pre-provisioned mode, except
that the Virtual Chassis Ports are not automatically discovered and
added, and the roles are not automatically defined; instead, a
priority-based election process occurs.

To create a VCF, you need to set the master RE switch into the VCF mode
with ``request virtual-chassis mode fabric reboot``.  At least one leaf
switch needs to be installed next, and it should be cabled to the second
spine switch before bringing up the second spine switch.

.. note::
   If you need a Mixed Mode :ref:`vcf`, such as when building a fabric
   with the QFX5100 and EX4300, you need to use the
   ``request virtual-chassis mode fabric mixed reboot`` operational
   command.  When operating a mixed mode :ref:`vcf`, you can set the
   master's mode to ``mixed``, then add all members, and then set all
   switches to ``mixed`` mode at the same time with the operational
   ``request virtual-chassis mode fabric mixed all-members reboot``
   command.

Mastership Election
^^^^^^^^^^^^^^^^^^^

In auto-provisioned and pre-provisioned, modes, the QFX5100 that has the
highest uptime is elected the master.  The QFX5100 with the
second-highest uptime is elected the backup.  Any other QFX5100s in the
spine role are line cards.  If one of the masters fails, then one of the
QFX5100 spines operating as a line card will be elected the new backup
following the same uptime rules.

For a non-provisioned VCF, the following rules dictate master selection:

1: Highest priority (default is 128)
2: QFX5100 operating as master prior to reboot
3: QFX5100 with longest uptime (greater than one minute)
4: QFX5100 with lowest MAC address

For the backup RE, the process is repeated.

.. note::
   You might notice that this the same mastership election process as
   for :ref:`vc`.

Control Plane
^^^^^^^^^^^^^

``vccpd`` runs on all nodes and is based on IS-IS.  It is responsible
for topology discovery.  It also distributes any VCCP-specific state
information.  For unicast traffic, shortest path first is used; however,
to support BUM traffic, bidirection multicast trees are used.  Finally,
for control plane traffic, a unique Class of Service queue is
automatically created and used.  All of this operational complexity is
abstracted by :ref:`vcf`.

When deploying a VCF, GRES, NSR, and NSB are used to keep the master and
backup REs in sync.

For console access, each switch runs a virtual console server.  When you
attach to the console of any member switch, this virtual console server
software automatically redirects your connection to the master RE.  Once
you're on the master RE, you can access a specific node with the
``request session member <id>`` command.

As with :ref:`vc`, the OOB management interface becomes a ``vme``
interface.

When a switch is removed, its member ID does not get released
automatically.  If you want to release the member ID to be used by the
next switch attached, you can use the
``request virtual-chassis recycle member-id <id>`` operational cmmand.

When adding a new switch, the software versions must be compatible.  You
can either upgrade the devices manually, or you can use the
``auto-sw-upgrade`` configuration.  When using this, you must have the
images for each series (EX4300, QFX3500, QFX5100) in your fabric on the
master RE or a remote URL.  Use the
``set virtual-chassis auto-sw-upgrade ex-4300 <path>`` configuration
command to set the path for an EX4300.  Replace ``ex-4300`` with
``qfx-3`` or ``qfx-5`` for the QFX3500 or QFX5100, respectively.

When performing a software upgrade, the Non-Stop Software Upgrade (NSSU)
feature can be used if using the ``preprovisioned`` mode.  Additionally,
``no-split-detection`` (covered in the :ref:`fabric-partition` section)
must be configured.

.. _data-plane:

Data Plane
^^^^^^^^^^

:ref:`vcf` has a concept of "Smart Trunks."  When two or more links
between two devices are connected, they will automatically form a LAG.
Each path is weighted based on the bandwidth ratio.  Traffic is
distributed across multiple unequal paths, taking into account the
minimum possible bandwidth on any links in the path.

A 16 byte Fabric Header is added to each packet received or sent by an
ingress or egress device, similar to MPLS.  It contains the incoming
member ID, incoming port ID, destination member ID, and destination port
ID, among other fields.

For load balancing hashing, the following fields are used:

Layer 2+Fabric Header:

* Source MAC
* Destination MAC
* Ethertype
* VLAN ID
* Incoming Port ID
* Incoming Member ID

Layer 3+4:

* Source IP
* Destination IP
* Source Port
* Destination Port
* Protocol
* Incoming Port ID
* Incoming Member ID
* Next Header (IPv6 Only)

If you need to convert an interface to a VCP, the
``request virtual-chassis vc-port set pic-slot <id> port <id> member <id>``
command can be used.  The ``member <id>`` corresponds to the FPC number
in the interface's representation.  To do the opposite, replace ``set``
with ``delete``.  For example,
``request virtual-chassis vc-port delete pic-slot 0 port 1 member 7``.

Finally, MAC learning is similar to a :ref:`vc`: when a member learns a
new MAC address, it notifies the master of the MAC address.  The master
then programs all other members with the MAC-to-interface entry.

BUM Traffic
^^^^^^^^^^^

BUM traffic is distributed according to a Multicast Distribution Tree
(MDT).  There are multiple trees in a :ref:`vcf`, each rooted at each
switch.  Therefore, there are ``N`` MDTs, where ``N`` is the number of
switches in the :ref:`vcf`.  Each switch can load balance across all of
the available MDTs for sending BUM traffic.  This traffic is hashed
based on the VLAN ID.

.. note::
   In a :ref:`vcf`, all members receive a copy of all BUM traffic.

.. _fabric-partition:

Fabric Partition
^^^^^^^^^^^^^^^^

Sometimes, a fabric may become partitioned or "split."  This occurs when
one or more switches become isolated from one or more other switches in
the fabric.  When this happens, one of the new fabrics will remain
active, and the others will be deactivated.

.. note::
   "Isolated" refers to communications via the Virtual Chassis Ports.
   Even if IP connectivity would otherwise exist, the fabric is
   considered partitioned if it cannot communicate over the VCPs.

To determine which fabric will remain active, the following rules are
evaluated, in order:

1: The fabric contains both the master and the backup RE from the
   previous fabric
2: The fabric contains the original master RE and at least half of the
   members from the previous fabric
2: The fabric contains the backup master RE and at least half of the
   members from the previous fabric

If your design can function when a partition happens, you can disable
the default behavior with the ``set virtual-chassis no-split-detection``
configuration command.  This disables the deactivation of partitioned
fabrics described above.

.. rubric:: Footnotes

.. [#f1] `Juniper QFX5100 Series <https://www.amazon.com/Juniper-QFX5100-Comprehensive-Building-Next-Generation/dp/1491949570/>`_
.. [#f2] `Planning a Virtual Chassis Fabric Deployment <https://www.juniper.net/documentation/en_US/release-independent/junos/topics/reference/requirements/virtual-chassis-fabric-hardware-planning.html>`_
.. [#f3] `Errata for Juniper QFX5100 Series <https://www.oreilly.com/catalog/errata.csp?isbn=0636920033028>`_
