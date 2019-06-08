Technology-Oriented Labs
========================

TODO: Flesh this out more.  A lot more.

Right now, this page is a sort of scratch pad on things that are likely
to be on the exam.  It's lab-oriented, with some specific implementation
details.

Lab 1 (Multicast and CRB with QFX)
----------------------------------

This lab should focus on multicast for BUM replication and VTEP
discovery.  It should implement VxLAN routing at the spine layer.  The
spines should be QFX10k Series devices.

Lab 2 (Multicast and CRB with MX)
---------------------------------

This lab should focus on multicast for BUM replication and VTEP
discovery.  It should implement VxLAN routing at the spine layer.  The
spines should be MX Series devices.

Lab 3 (Multicast and ERB)
-------------------------

This lab should focus on multicast for BUM replication and VTEP
discovery.  It should implement VxLAN routing at the leaf layer.  Use
either the QFX10k or QFX5110 Series for the leaf layer.

Lab 4 (EVPN and CRB with QFX)
-----------------------------

This lab should focus on BGP EVPN and ingress replication for VTEP
discovery.  It should implement VxLAN routing at the spine layer.  The
spines should be QFX10k Series devices.

Lab 5 (EVPN and CRB with MX)
----------------------------

This lab should focus on BGP EVPN and ingress replication for VTEP
discovery.  It should implement VxLAN routing at the spine layer.  The
spines should be MX Series devices.

Lab 6 (EVPN and ERB)
--------------------

This lab should focus on BGP EVPN and ingress replication for VTEP
discovery.  It should implement VxLAN routing at the leaf layer.  Use
either the QFX10k or QFX5110 Series for the leaf layer.

Lab 7 (EVPN Multihoming with QFX)
---------------------------------

This lab should focus on EVPN using a QFX at the leaf layer.  Use any of
labs 3 through 6 as the base topology and add EVPN Multihoming at the
leaf layer with a QFX Series device.

Lab 8 (EVPN Multihoming with MX)
---------------------------------

This lab should focus on EVPN using an MX at the leaf layer.  Use any of
labs 3 through 6 as the base topology and add EVPN Multihoming at the
leaf layer with an MX Series device.

Lab 9 (DCI with MX Series EVPN Stitching)
-----------------------------------------

Implement a DCI solution with lab 7 or 8 as a starting point and MX
Series devices as WAN routers.  They should stitch a VxLAN EVPN to an
MPLS EVPN solution.

Lab 10 (DCI with MX Series L3VPN)
---------------------------------

Implement a DCI solution with lab7 or 8 as a starting point and MX
Series devices as WAN routers.  The VxLAN EVPN solution should simply
ride over a normal MPLS L3VPN.

Lab 11 (DCI with VxLAN EVPN and MX)
-----------------------------------

Implement a DCI solution with lab7 or 8 as a starting point and MX
Series devices as spines.  The solution should be implemented using only
VxLAN BGP EVPN.

Lab 11 (DCI with VxLAN EVPN and QFX)
------------------------------------

Implement a DCI solution with lab7 or 8 as a starting point and QFX10k
Series devices as spines.  The solution should be implemented using only
VxLAN BGP EVPN.
