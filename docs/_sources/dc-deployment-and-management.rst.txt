Data Center Deployment and Management
=====================================

This blueprint item covers a number of topics:

* :ref:`ztp`
* :ref:`ha`
* :ref:`monitoring`
* :ref:`analytics`

Unfortunately, the blueprint doesn't indicate to what level those items
should be known, and all of those options seem to require physical
hardware, which I do not have.  So this guide will only be theory until
someone contributes configuration sections.

.. _ztp:

Zero-Touch Provisioning
-----------------------

ZTP is a process for upgrading software and applying configuration
automatically on first boot.  This is accomplished by using a stadard
DHCP server with a little bit of extra configuration so that each
``DISCOVER`` is associated with the correct switch so that the correct
configuration can be retrieved.

When configuring the DHCP server, the following DHCP options can be
used:

* ``12``: Switch Hostname
* ``42``: NTP Server
* ``43.00``: Software image filename
* ``43.01``: Configuration file filename
* ``43.02``: Symbolic link flag for filename
* ``43.03``: Transfer mode (HTTP, FTP, TFTP)
* ``43.04``: Alternate software image filename
* ``66``: DNS FQDN for the HTTP/FTP/TFTP server
* ``150``: IP Address for the HTTP/FTP/TFTP server

The reason that both ``44.00`` and ``44.04`` can both be used is that
some DHCP servers may not support ``44.00``.  If both options are
defined, ``44.00`` takes precedence.

When setting the ``44.00`` or ``44.04`` location to a symlink, you also
need to set the ``44.02`` option to the value ``symlink`` so that the
system knows that the image is a symlink.

``44.03`` lets you specify whether the file transfer method will be FTP,
TFTP, or HTTP.  The default is TFTP.

If DHCP options ``66`` and ``150`` are both specified, then ``150``
takes precedence.

When the configuration file starts with a shebang (``#!``), Junos will
attempt to run the file as a script.  This means you can use one Python
or shell script to dynamically configure your switches instead of
handcrafting a configuration file for each switch.

By default, a QFX5100 will attempt to perform ZTP through both its
management interface and its revenue ports.  This means you can perform
ZTP through a dedicated OOB management network (recommended) or in-band.

After the switch knows the details of its ZTP process, it first
downloads the required configuration file and then the required software
image (if necessary).  If a software image was downloaded, then the
switch performs the software upgrade.  Finally, it applies the
configuration file that was downloaded.

ZTP can also be performed by Junos Space with Network Director.  When
this is done, the switch is automatically added to Network Director for
future management.

For more information on ZTP (including configuration examples), see the
following blogs/articles:

* `Zero Touch Provisioning: How to Build a Network Without Touching Anything <https://blog.digitalocean.com/zero-touch-provisioning-how-to-build-a-network-without-touching-anything/>`_
* `Zero Touch Provisioning on Juniper devices using Linux <https://nextheader.net/2015/09/02/zero-touch-provisioning-on-juniper-devices-using-linux/>`_

You can also read Chapter 6 of the QFX5100 Series book from O'Reilly [#f1]_.

.. _ha:

High Availability
-----------------

The QFX5100 has a virtualized control plane.  There is a Linux host
running KVM, and Junos runs as a VM.  The hypervisor can run up to four
VMs: two of them are reserved for Junos, one is a guest of the
operator's choice, and the last is reserved.

Each Junos VM has four management interfaces.  The first two, ``em0``
and ``em1``, map to the physical management ports on the switch.  The
third, ``em2``, is used for communicating with the hypervisor.  The last
interface, ``em3``, is used when performing a Topology-independent
In-Service Software Upgrade, or TISSU.  The second Junos VM is only
created during a TISSU.  In order to perform a TISSU, NSR, NSB, and GRES
must be configured.

The high-level process for TISSU is as follows [#f2]_:

1: Create the backup Junos VM running the new version requested
2: Synchronize state between the Junos VMs using ``ksyncd``
3: Makes the new VM the master RE
4: Renames the slot ID of the new VM from ``1`` to ``0``
5: The former master Junos VM is shut down

When performing a TISSU, keep the following in mind:

* Downgrades and rollbacks are not supported
* TISSU should not be used when transitioning between different base
  images (e.g., ``standard`` to ``enhanced-automation``)
* The CLI is inaccessible during a TISSU
* Log files are located in ``/var/log/vjunos-log.tgz``
* BFD timers need to be >= 1 second [#f3]_
* ``system internet-options no-tcp-reset drop-all-tcp`` must not be
  configured [#f3]_

A configuration sample for enabling NSR, NSB, and GRES is below.

.. literalinclude:: configs/deployment-and-management/issu.cfg
    :language: perl

Once the configuration is in place, you can perform a TISSU with the
``request system software in-service-upgrade <path-to-image>`` command.

For more information, see Chapter 2 of the Juniper QFX5100 Series book
[#f1]_.

.. _monitoring:

Monitoring
----------

Junos supports streaming telemetry as well as more traditional methods
of monitoring such as SNMP.

TODO: Add configuration for SNMPv2c, SNMPv3, and Streaming Telemetry.

.. _analytics:

Analytics
---------

The QFX5100 supports two methods of analytics: sFlow and Enhanced
Analytics.  These are described below, but it's important to understand
that they should be used together as neither provides the entire picture
on its own.

sFlow
^^^^^

The QFX5100 supports sFlow, which samples every ``n`` packets.  This
sampled data is exported every 1500 bytes or every 250ms.  Any alerting
on this data must be performed off-box with the sFlow collector.  On the
QFX5100, only switchports can be sampled.  Layer 3 interfaces cannot be
sampled.  The first 128 bytes of the packet are sampled, and this
includes information such as the source and destination MACs, IPs, and
Ports.  Higher sampling rates require more processing power.

To combat this on high-traffic switches, the QFX5100 can dynamically
adjust sample rates based on interface traffic.  This is known as
adaptive sampling.  An agent checks the interfaces every 5 seconds.
A list of the top five interfaces is created.  An algorithm reduces the
load by half for the top five interfaces and allocates those samples to
lower traffic interfaces.

An sFlow configuration is shown below.

.. literalinclude:: configs/deployment-and-management/sflow.cfg
    :language: perl

.. note::
   The ``polling-interval`` tells Junos how frequently, in seconds, to
   poll for data; the ``sampling-rate`` tells Junos how many packets to
   sample.

Juniper Enhanced Analytics
^^^^^^^^^^^^^^^^^^^^^^^^^^

The QFX5100 also supports Juniper Enhanced Analytics.  This system can
poll as frequently as every 8ms, and data is exported as soon as it is
collected.  You can set thresholds on-box down to 1ns.  Enhanced
Analytics can monitor:

* Traffic statistics
* Queue depth
* Latency
* Jitter

This data can be streamed using the following formats:

* Protobuf
* JSON
* CSV
* TSV

Enhanced Analytics is performed by two systems: the Analytics Daemon and
the Analytics Manager.

The Analytics Daemon (``analyticsd``) collects information from the
Analytics Manager's ring buffers and exports it to collectors.

The Analytics Manager runs in the PFE and collects the data that is
placed into ring buffers for ``analyticsd`` to collect.

TODO: Add configuration examples for Enhanced Analytics.

For more information, see Chapter 9 of the Juniper QFX5100 Series book
[#f1]_.

.. rubric:: Footnotes

.. [#f1] `Juniper QFX5100 Series <https://www.amazon.com/Juniper-QFX5100-Comprehensive-Building-Next-Generation/dp/1491949570/>`_
.. [#f2] `Understanding In-Service Software Upgrade (ISSU) <https://www.juniper.net/documentation/en_US/junos/topics/concept/issu-on-qfx5100-overview.html>`_
.. [#f3] `Performing an In-Service Software Upgrade (ISSU) with Non-Stop Routing <https://www.juniper.net/documentation/en_US/junos/topics/task/installation/issu-upgrading-qfx5100.html>`_
