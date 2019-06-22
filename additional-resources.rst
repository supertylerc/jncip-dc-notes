Additional Resources
====================

Although I've tried to provide references on each page, they can become
lost pretty easily.  For that reason, this page includes references for
books, feature guides, solutions guides, videos, and blogs that might be
helpful when studying for the JNCIP-DC exam.

Data Center Deployment or Management
------------------------------------

The `QFX5100 Series <https://www.amazon.com/Juniper-QFX5100-Comprehensive-Building-Next-Generation/dp/1491949570/>`_
book from O'Reilly is a great resources for this section of the
blueprint.  Check chapters 6 (Network Automation) and 9 (Network
Analytics) specifically.

A good blog post for ZTP is `this one from NextHeader <https://nextheader.net/2015/09/02/zero-touch-provisioning-on-juniper-devices-using-linux/>`_.
It includes a topology diagram, switch outputs, configuration of an ISC
DHCP Server on Ubuntu, and pcaps.

As you'll see throughout this list of resources, the blog over at
`<https://jncie.tech/>`_ has a blog on ZTP: `JNCIE TECH - Zero Touch Provisioning <https://jncie.tech/2017/07/07/zero-touch-provisioning/>`_.

Finally, there is an older Juniper Day One book on `Deploying Zero Touch Provisioning <https://www.amazon.com/Day-One-Deploying-Touch-Provisioning-ebook/dp/B0195KUGV8>`_.
It's focused on the EX and SRX Series, but it should still serve as a
useful reference.

.. _mc-lag-resource:

Multichassis LAG
----------------

For MC-LAG, check out the `MX Series <https://www.amazon.com/Juniper-MX-Comprehensive-Guide-Technologies/dp/1491932724/>`_
book from O'Reilly.  Chapter 9 is all about Multi-Chassis Link Aggregation.

This will cover you on the MX side, but there's still MC-LAG on the QFX
to worry about.  It's very similar, so it shouldn't be too difficult.
Another great resource is the official `Multichassis Link Aggregation Feature Guide <https://www.juniper.net/documentation/en_US/junos/information-products/pathway-pages/mc-lag/multichassis-link-aggregation-groups.html>`_.

The following list of blogs can be useful, too:

- `JNCIE TECH - MC-LAG Overview <https://jncie.tech/2017/07/10/mc-lag/>`_
- `JNCIE TECH - MC-LAG Lab - Basic L2 Connectivity <https://jncie.tech/2017/07/29/mc-lag-lab-basic-l2-connectivity/>`_
- `JNCIE TECH - MC-LAG Lab - Advanced IRB Functionality <https://jncie.tech/2017/07/30/mc-lag-lab-advanced-irb-functionality/>`_
- `Christians Juniper Blog - MC-LAG on vQFX (EVE-NG) <https://jncie.eu/mc-lag-on-vqfx-eve-ng/>`_

Layer 2 Fabrics
---------------

For Virtual Chassis, a great resource is `Understanding Mixed EX Series and QFX Series Virtual Chassis <https://www.juniper.net/documentation/en_US/junos/topics/concept/virtual-chassis-ex-qfx-series-mixed-understanding.html>`_.
This will help you understand some limitations of mixed mode Virtual
Chassis with EX and QFX Series switches.  For configuration, check
`Configuring a QFX Virtual Chassis <https://www.juniper.net/documentation/en_US/junos/topics/task/configuration/virtual-chassis-qfx-series-cli.html>`_.
For a more general Virtual Chassis read, check out the `Junos Enterprise Switching <https://www.amazon.com/JUNOS-Enterprise-Switching-Practical-Certification/dp/059615397X/>`_
book, specifically Chapter 4, EX Virtual Chassis.  Finally, the `Day One: EX Series Up and Running <https://www.juniper.net/us/en/training/jnbooks/day-one/fabric-switching-tech-series/ex-series-up-running/>`_
book has two chapters on Virtual Chassis - Chapters 4 and 5.

For Virtual Chassis Fabric, you can read the `QFX5100 Series <https://www.amazon.com/Juniper-QFX5100-Comprehensive-Building-Next-Generation/dp/1491949570/>`_
book.  Chapter 5 is dedicated to Virtual Chassis Fabric.  Another good
reference is the `Day One: Data Center Fundamentals <https://www.juniper.net/us/en/training/jnbooks/day-one/fundamentals-series/data-center/>`_
book.  Chapter 5 covers fabric architectures, including
:ref:`mc-lag-resource`, Virtual Chassis, and Virtual Chassi Fabric.
Finally, the `Virtual Chassis Fabric Feature Guide <https://www.juniper.net/documentation/en_US/junos/information-products/pathway-pages/qfx-series/virtual-chassis-fabric.html>`_
is a great resource for all things Virtual Chassis Fabric.  For a dive
into best practices, check the `Best Practices: Virtual Chassis Best Practices Guide <https://www.juniper.net/documentation/en_US/release-independent/vcf/information-products/pathway-pages/vcf-best-practices-guide.pdf>`_.

For blogs, `<https://jncie.tech>`_ comes in again with `JNCIE TECH - VCF <https://jncie.tech/2017/07/08/vcf/>`_.

Layer 3 Fabrics
---------------

This one is a potentially large topic, and there are a number of
resources for it, including white papers, RFCs, and books.

First, there is the `Clos IP Fabrics with QFX5100 Switches <https://www.juniper.net/us/en/local/pdf/whitepapers/2000565-en.pdf>`_
white paper.  This is all about the layer 3 underlay with a strong focus
on BGP.  Both eBGP and iBGP (with route reflectors) are covered.

Next, in terms of books, there is the `QFX5100 Series <https://www.amazon.com/Juniper-QFX5100-Comprehensive-Building-Next-Generation/dp/1491949570/>`_
book.  Chapter 7 is all about IP fabrics, although its content seems to
be largely the same as the afore-mentioned white paper.  Another good
reference is Chapter 6 of the `Day One: Data Center Fundamentals <https://www.juniper.net/us/en/training/jnbooks/day-one/fundamentals-series/data-center/>`_
book.  This chapter is, again, completely dedicated to Layer 3 fabrics.

.. note::
   For a much more in-depth treatise on BGP in the Data Center, see the
   `book of the same name <https://learning.oreilly.com/library/view/bgp-in-the/9781491983416/>`_.
   This book focuses on Free-Range Routing (FRR, the routing software
   used in Cumulus), but 100% of the theory applies here.

Finally, there is informational `RFC 7938, Use of BGP for Routing in Large-Scale Data Centers <https://tools.ietf.org/html/rfc7938>`_.

If blogs are more your speed, the only one I've found that seems
appropriately scoped for this topic only is `JNCIE TECH - IP Fabric <https://jncie.tech/2017/07/11/ip-fabric/>`_.
`Juniper QFX, IP-Fabric and VXLAN -- Part <http://www.networkers.fi/blog/juniper-qfx-ip-fabric-and-vxlan-part-1/>`_
may be helpful as well, but it also includes some multicast
configuration, which I generally lump in with VxLAN.

VxLAN
-----

This is a massive topic.  The list of resources here will intentionally
ignore EVPN as that is listed as a separate topic in the syllabus.

For books, the `QFX5100 Series <https://www.amazon.com/Juniper-QFX5100-Comprehensive-Building-Next-Generation/dp/1491949570/>`_
is again a great resource.  Chapter 8 covers Overlay Networking.  `Day One: Data Center Fundamentals <https://www.juniper.net/us/en/training/jnbooks/day-one/fundamentals-series/data-center/>`_
covers VxLAN in Chapter 7, Overlay Networking.

For blogs, we have a few to choose from:

- `Juniper QFX, IP-Fabric and VXLAN -- Part 1 <http://www.networkers.fi/blog/juniper-qfx-ip-fabric-and-vxlan-part-1/>`_
- `Juniper QFX, IP-Fabric and VXLAN -- Part 2 <http://www.networkers.fi/blog/juniper-qfx-ip-fabric-and-vxlan-part-2/>`_
- `JNCIE TECH - VXLAN Multicast <https://jncie.tech/2017/07/15/vxlan-multicast/>`_

These next two are from Cumulus, but they should still help explain
gateway placement options:

- `VXLAN Designs: 3 Ways to Consider Routing and Gateway Design (Part 1) <https://cumulusnetworks.com/blog/vxlan-designs-part-1/>`_
- `VXLAN Designs: 3 Ways to Consider Routing and Gateway Design (Part 2) <https://cumulusnetworks.com/blog/vxlan-designs-part-2/>`_

The next set are specific to Cisco, but if you're familiar with NX-OS,
you might find them helpful.  They're also good for general theory.

- `The Network Times - VXLAN Part I: Why do we need VXLAN? <https://nwktimes.blogspot.com/2018/02/vxlan-part-i-why-vxlan-is-needed.html>`_
- `The Network Times - VXLAN Part III: The Underlay Network -- Multidestination Traffic: Anycast-RP with PIM <https://nwktimes.blogspot.com/2018/03/vxlan-part-iv-underlay-network.html>`_
- `The Network Times - VXLAN Part V: Flood and Learn <https://nwktimes.blogspot.com/2018/03/vxlan-part-v-flood-and-learn.html>`_

If videos are your speed, here are a list of YouTube resources:

- `Introduction to Cloud Overlay Networks - VxLAN <https://www.youtube.com/watch?v=Jqm_4TMmQz8>`_ by `David Mahler <https://twitter.com/davidmahler>`_
- `VxLAN Playlist <https://www.youtube.com/watch?v=YNqKDI_bnPM&list=PLDQaRcbiSnqFe6pyaSy-Hwj8XRFPgZ5h8>`_ by `Network Direction <https://www.youtube.com/channel/UCtuXekfqj-paqsxtqVNCC2A>`_
- `VxLAN 101 <https://www.youtube.com/watch?v=qujBqnSQHVQ>`_ by `Ivan Pepelnjak <https://twitter.com/ioshints>`_

EVPN VxLAN Signaling
--------------------

For books, we start with the `Day One: Data Center Fundamentals <https://www.juniper.net/us/en/training/jnbooks/day-one/fundamentals-series/data-center/>`_
book, which covers EVPN in Chapter 9.  From there, we can look to the
`QFX10000 Series <https://www.amazon.com/Juniper-QFX10000-Comprehensive-Building-Next-Generation-ebook/dp/B01J6MYF58/>`_
book.  Chapter 6 covers Ethernet VPN.  We also have the `This Week: Data Center Deployment EVPN/VXLAN <https://www.juniper.net/us/en/training/jnbooks/day-one/data-center-technologies/data-center-deployment-evpn-vxlan/>`_
book.

.. note::
   `EVPN in the Data Center <https://learning.oreilly.com/library/view/evpn-in-the/9781492029045/>`_
   is a great book for learning about EVPN.  Its primary focus is FRR,
   but all of the theory and concepts apply to Junos as well.

The following guides will also be useful:

- `Solution Guide: Infrastructure as a Service: EVPN and VXLAN <https://www.juniper.net/documentation/en_US/release-independent/solutions/information-products/pathway-pages/sg-003-evpn-vxlan.html>`_
- `EVPN Feature Guide <https://www.juniper.net/documentation/en_US/junos/information-products/pathway-pages/junos-sdn/evpn-vxlan.html>`_
- `Cloud Data Center Architecture Guide <https://www.juniper.net/documentation/en_US/release-independent/solutions/information-products/pathway-pages/sg-005-cloud-data-center.html>`_
- `EVPN LAG Multihoming in EVPN-VXLAN Cloud Data Center Infrastructures <https://www.juniper.net/documentation/en_US/release-independent/solutions/information-products/pathway-pages/evpn-lag-multihoming-guide/evpn-lag-multihoming-guide.html>`_
- `Juniper Networks EVPN Implementation for Next-Generation Architectures <https://juniper.net/assets/us/en/local/pdf/whitepapers/2000606-en.pdf>`_

For blog posts, we again have a large number of posts to dive into:

- `Christians Juniper Blog - EVPN-VXLAN on (v)QFX-Series Devices <https://jncie.eu/evpn-vxlan-on-vqfx-series-devices/>`_
- `Dan Hearty - Juniper QFX10K | EVPN-VXLAN | MAC Learning Verification | Single-Homed Endpoint <https://danhearty.wordpress.com/2018/02/22/juniper-qfx10k-evpn-vxlan-mac-learning-verification-single-homed-endpoint/>`_
- `Dan Hearty - Juniper QFX10K | EVPN-VXLAN | EVPN Anycast Gateway Verification <https://danhearty.wordpress.com/2018/03/28/juniper-qfx10k-evpn-vxlan-evpn-anycast-gateway-verification/>`_
- `Dan Hearty - Juniper QFX10k | EVPN-VXLAN | IRB Routing | BGP <https://danhearty.wordpress.com/2019/05/04/juniper-qfx10k-evpn-vxlan-irb-routing-bgp/>`_
- `JNCIE TECH - EVPN-VXLAN Lab - Basic L2 Switching <https://jncie.tech/2017/08/01/evpn-vxlan-lab-basic-l2-switching/>`_
- `JNCIE TECH - EVPN-VXLAN Lab - RT Assignment Methods <https://jncie.tech/2017/08/03/evpn-vxlan-lab-rt-assignment-methods/>`_
- `JNCIE TECH - EVPN-VXLAN Lab - IRB Functionality <https://jncie.tech/2017/08/05/evpn-vxlan-lab-irb-functionality/>`_
- `JNCIE TECH - MX EVPN-VXLAN Basic Config <https://jncie.tech/2017/07/18/mx-evpn-vxlan-basic-config/>`_
- `JNCIE TECH - QFX EVPN Basic Config <https://jncie.tech/2017/07/19/qfx-evpn-basic-config/>`_
- `JNCIE TECH - EVPN-VXLAN RT Communities <https://jncie.tech/2017/07/20/evpn-vxlan-rt-communities/>`_
- `Lab on EVPN -- VXLAN on QFX5100 Switches <https://blog.noc.grnet.gr/2016/09/28/lab-on-evpn-vxlan-on-juniper-qfx5100-switches-3/>`_
- `VXLAN Routing with EVPN: Asymmetric vs. Symmetric Model <https://cumulusnetworks.com/blog/asymmetric-vs-symmetric-model/>`_
  (this is a Cumulus post, but it's still very helpful)

Next, some Cisco Nexus-centric blog posts:

- `The Network Times - VXLAN Part VI: VXLAN BGP EVPN -- Basic Configurations <https://nwktimes.blogspot.com/2018/04/vxlan-part-vi-vxlan-bgp-evpn-basic.html>`_
- `The Network Times - VXLAN Part VII: VXLAN BGP EVPN -- Control Plane Operation <https://nwktimes.blogspot.com/2018/05/vxlan-part-vii-vxlan-bgp-evpn-control.html>`_
- `The Network Times - VXLAN Part VIII: VXLAN BGP EVPN -- External Connection <https://nwktimes.blogspot.com/2018/06/vxlan-part-viii-vxlan-bgp-evpn-external.html>`_
- `The Network Times - VXLAN Part XII: Routing Exchange -- Intra/Inter-L2VNI, EVPN-to-IP, EVPN-to-VPNv4 <https://nwktimes.blogspot.com/2018/09/vxlan-part-xii-routing-exchange.html>`_
- `The Network Times - VXLAN Part XIV: Control Plane Operation in BGP EVPN VXLAN Fabric <https://nwktimes.blogspot.com/2018/11/vxlan-part-xiv-control-plane-operation.html>`_
- `The Network Times - VXLAN Part XV: Analysis of the BGP EVPN Control Plane Operation <https://nwktimes.blogspot.com/2018/12/vxlan-part-xv-analysis-of-bgp-evpn.html>`_

Some videos from YouTube that might help:

- `Juniper Networks EVPN - VXLAN Architecture <https://www.youtube.com/watch?v=EBjPve8AmR4>`_
  from Tech Field Day
- `Building Blocks in EVPN for Multi-Service Fabrics <https://www.youtube.com/watch?v=I1gPiWACgUo>`_
  from NANOG 75

Data Center Interconnect
------------------------

DCI is a pretty big topic with quite a few ways to implement.  Most of
the materials I've seen so far seem to focus on straight VxLAN EVPN
connectivity.  However, there's at least one blog post from JNCIE TECH
(listed below) that covers EVPN stitching.

Books that may be useful:

- `Day One: Using Ethernet VPNs for Data Center Interconnect <https://www.juniper.net/us/en/training/jnbooks/day-one/proof-concept-labs/using-ethernet-vpns/>`_
- `Day One: MPLS Up and Running <https://www.juniper.net/us/en/training/jnbooks/day-one/mpls-up-running-on-junos/>`_
- `Day One: MPLS for Enterprise Engineers <https://www.juniper.net/us/en/training/jnbooks/day-one/networking-technologies-series/mpls-enterprise-engineers/>`_

.. note::
   Two of the books above are on MPLS basics.  For better or worse, it
   looks like a portion of this track relies on MPLS.  I've added the
   two references references above in case you are coming directly from
   the Enterprise track, which is a prerequisite for the DC track but
   has no MPLS coverage.

Blog posts:

- `JNCIE TECH - MX EVPN-MPLS Basic Config <https://jncie.tech/2017/07/17/mx-evpn-mpls-basic-config/>`_
- `JNCIE TECH - MX EVPN IRB Functionality <https://jncie.tech/2017/07/21/mx-evpn-irb-functionality/>`_
- `JNCIE TECH - EVPN-VXLAN to EVPN-MPLS Stitching <https://jncie.tech/2017/07/23/evpn-vxlan-to-evpn-mpls-stitching/>`_

Videos from YouTube:

- `BGP EVPN in Datacenter and Layer 3 Data Center Interconnect <https://www.youtube.com/watch?v=nPKLe0M5yJU>`_
  from NANOG 66 (This is Cisco, but theory should mostly apply)

Data Center Architecture and Security
-------------------------------------

This seems to be a pretty nebulous topic.  The only items in the
syllabus that are listed seem security-related, so I'm just going to
focus on that.  First, a list of Day One books:

- `Day One: Configuring Junos Policies and Firewall Filters <https://www.juniper.net/us/en/training/jnbooks/day-one/fundamentals-series/configuring-junos-policies/>`_
- `This Week: Hardening Junos Devices, 2nd Edition <https://www.juniper.net/us/en/training/jnbooks/day-one/fundamentals-series/hardening-junos-devices-checklist/>`_
- `Day One: Deploying BGP Routing Security <https://www.juniper.net/us/en/training/jnbooks/day-one/deploying-bgp-routing-security/>`_

Next, the `MX Series <https://www.amazon.com/Juniper-MX-Comprehensive-Guide-Technologies/dp/1491932724/>`_
book has an entire chapter dedicated to Routing Engine Protection and
DDoS Prevention (Chapter 4).

Finally, a couple of blog posts:

- `iNetZero - EVPN-VXLAN Inter-tenant Routing on Juniper QFX/MX <https://www.inetzero.com/qfxmxevpn/>`_
- `Dan Hearty - Using JUNOS Firewall Filters for Troubleshooting & Verification | QFX5110 <https://danhearty.wordpress.com/2018/07/09/using-junos-firewall-filters-for-troubleshooting-verification-qfx5110/>`_

Miscellaneous
-------------

Some topics that are probably important but don't seem to be called out
explicitly in the syllabus:

- Oversubscription: `Day One: Data Center Fundamentals <https://www.juniper.net/us/en/training/jnbooks/day-one/fundamentals-series/data-center/>`_
  has this covered in Chapter 4, while `QFX5100 Series <https://www.amazon.com/Juniper-QFX5100-Comprehensive-Building-Next-Generation/dp/1491949570/>`_
  covers it in Chapter 3, Performance and Scaling.
- Virtual Machine Traffic Optimization (VMTO): `Comparing Layer 3 Gateway & Virtual Machine Traffic Optimization (VMTO) for EVPN/VXLAN and EVPN/MPLS <https://www.juniper.net/documentation/en_US/release-independent/solutions/information-products/pathway-pages/solutions/l3gw-vmto-evpn-vxlan-mpls.pdf>`_.
  I'm honestly not sure where this fits in, but it's listed under
  ``Additional Resources`` on the `JNCIP-DC Certification Page <https://www.juniper.net/us/en/training/certification/certification-tracks/data-center-track/?tab=jncip-dc>`_.