---
coding: utf-8

title: Crowd Sourced Remote ID
abbrev: CS-RID
docname: draft-wiethuechter-drip-csrid-02
category: std

ipr: trust200902
area: Internet
wg: drip Working Group
kw: Internet-Draft
cat: std

stand_alone: yes
pi: [toc, sortrefs, symrefs, comments]

author:
- ins: R. Moskowitz
  name: Robert Moskowitz
  org: HTT Consulting
  street: ''
  city: Oak Park
  region: MI
  code: '48237'
  country: USA
  email: rgm@labs.htt-consult.com
- ins: A. Wiethuechter
  name: Adam Wiethuechter
  org: AX Enterprize
  street: 4947 Commercial Drive
  city: Yorkville
  region: NY
  code: '13495'
  country: USA
  email: adam.wiethuechter@axenterprize.com

normative:
  RFC9153:  # DRIP Req.

informative:
  DIME-ARCH: I-D.ietf-drip-registries
  DRIP-AUTH: I-D.ietf-drip-auth
  MOSKOWITZ-CSRID: I-D.moskowitz-drip-crowd-sourced-rid
  
  RFC5238:  # DTLS
  RFC4303:  # ESP
  RFC7049:  # CBOR
  RFC7252:  # COAP
  RFC7401:  # HIPv2
  RFC7748:  # elliptic curves
  RFC8032:  # EdDSA
  RFC8610:  # CDDL
  RFC9374:  # DET
  RFC9434:  # DRIP Arch

  FAA-FR:
    target: https://www.govinfo.gov/content/pkg/FR-2021-01-15/pdf/2020-28948.pdf
    title: FAA Remote Identification of Unmanned Aircraft
    author:
    - org: United States Federal Aviation Administration (FAA)
    date: 2021-01
  F3411:
    title: Standard Specification for Remote ID and Tracking
    author:
      - 
        org: ASTM International
    target: https://www.astm.org/f3411-22a.html
    date: July 2022
    seriesinfo:
      ASTM: F3411-22A
      DOI: 10.1520/F3411-22A
  GPS-IONOSPHERE:
    target:  https://doi.org/10.1002/2015JA021629
    title: Ionospheric response to the 2015 St. Patrick's Day storm A global multi-instrumental overview
    author:
    - org: Unknown
    date: 2015-09

--- abstract

This document describes a way for an Internet connected device to forward/proxy received Broadcast Remote ID into UAS Traffic Management (UTM). This is done through a Supplemental Data Service Provider (SDSP) that takes Broadcast Remote ID in from Finder and provides an aggregated view using Network Remote ID data models and protocols. This enables more comprehensive situational awareness and reporting of Unmanned Aircraft (UA) in a "crowd sourced" manner.

--- middle

# Introduction

> Note: This document is directly related and builds from {{MOSKOWITZ-CSRID}}. That draft is a "top, down" approach to understand the concept and high level design. This document  is a "bottom, up" implementation of the CS-RID concept. The content of this draft is subject to change and adapt as further development continues.

This document defines a mechanism to capture {{F3411}} Broadcast Remote ID (RID) messages on any Internet connected device that receives them and can forward them to Supplemental Data Service Providers (SDSPs) responsible for the geographic area the UA and receivers are in. This data can be aggregated and further decimated to other entities in Unmanned Aircraft Systems (UAS) Traffic Management (UTM) similar to {{F3411}} Network RID. It builds upon the introduction of the concepts and terms found in {{RFC9434}}. We call this service Crowd Sourced RID (CS-RID).

## Role of Finders

These Internet connected devices are herein called "Finders", as they find UAs by listening for Broadcast RID. The Finders are Broadcast RID forwarding proxies. Their potentially limited spacial view of RID messages could result in bad decisions on what messages to send to the SDSP and which to drop. Thus they SHOULD send all received messages and the SDSP will make any filtering decisions in what it forwards into the UTM.

Finders can be smartphones, tablets, connected cars, special purpose devices or any computing platform with Internet connectivity that can meet the requirements defined in this document. It is not expected, nor necessary, that Finders have any information about a UAS beyond the content found in Broadcast RID.

## Role of Supplemental Data Service Providers

The SDSP provides a gateway service for supplemental data into UTM. This document focuses on RID exclusively, other types of supplemental data is out of scope for this document.

The primary role of a CS-RID SDSP is to aggregate reports from Finders and forward them as a subscription based service to UTM clients. These clients MAY be a USS or another SDSP. An CS-RID SDSP SHOULD NOT proxy raw data/reports into UTM. An CS-RID SDSP MAY provide such a service, but it is out of scope for this document.

An SDSP MAY have its coverage constrained to a manageable area that has value to its subscribers. An CS-RID SDSP MAY not allow public reports of Broadcast RID due to policy. Policies of SDSPs is out of scope for this document.

{{F3411}} Network RID is the defined interface (protocol and model) for an SDSP to provide Broadcast RID as supplemental data to UTM.

## Relationship between Finders & SDSPs

Finders MAY only need a loose association with SDSPs. The SDSP MAY require a stronger relationship to the Finders. The relationship MAY be completely open, but still authenticated to requiring encryption. The transport MAY be client-server based (using things like HIP or DTLS) to client push (using things like UDP or HTTPS).

# Document Objectives

This document standardizes transports between the Finder and SDSP. It also gives an overview of Network RID. Specific details of Network RID is out scope for this document. All models are specified in CDDL {{RFC8610}}.

# Terms and Definitions

## Requirements Terminology

{::boilerplate bcp14}

This document uses terms defined in {{RFC9153}} and {{RFC9434}}.

## Definitions

ECIES:

: Elliptic Curve Integrated Encryption Scheme. A hybrid encryption scheme which provides semantic security against an adversary who is allowed to use chosen-plaintext and chosen-ciphertext attacks.

Finder:

: In Internet connected device that can receive Broadcast RID messages and forward them to an SDSP.

Multilateration:

: Multilateration (more completely, pseudo range multilateration) is a navigation and surveillance technique based on measurement of the times of arrival (TOAs) of energy waves (radio, acoustic, seismic, etc.) having a known propagation speed.

# Problem Space

Broadcast and Network RID formats are both defined in {{F3411}} using the same data dictionary. Network RID is specified in JSON sent over HTTPS while Broadcast RID is octet structures sent over wireless links.

## Advantages of Broadcast Remote ID

Advantages over Network RID include:

- more readily be implemented directly in the UA. Network RID will more frequently be provided by the GCS or a pilot's Internet connected device.
  - If Command and Control (C2) is bi-directional over a direct radio connection, Broadcast RID could be a straight-forward addition.
  - Small IoT devices can be mounted on UA to provide Broadcast RID.
- also be used by the UA to assist in Detect and Avoid (DAA).
- is available to observers even in situations with no Internet like natural disaster situations.

## Meeting the needs of Network Remote ID

The USA Federal Aviation Administration (FAA), in the January 2021 Remote ID Final rule {{FAA-FR}}, postponed Network Remote ID and focused on Broadcast Remote ID. This was in response to the UAS vendors comments that Network RID places considerable demands on then currently used UAS.

However, Network RID, or equivalent, is necessary for UTM knowing what soon may be in an airspace and is mandated as required in the EU. A method that proxies Broadcast RID into UTM can function as an interim approach to Network RID and continue adjacent to Network RID.

## Trustworthiness of Proxy Data

When a proxy is introduced in any communication protocol, there is a risk of corrupted data and DOS attacks.

The Finders, in their role as proxies for Broadcast RID, SHOULD be authenticated to the SDSP (see {{session-security}}). The SDSP can compare the information from multiple Finders to isolate a Finder sending fraudulent information. SDSPs can additionally verify authenticated messages that follow {{DRIP-AUTH}}.

The SPDP can manage the number of Finders in an area (see {{managing-finders}}) to limit DOS attacks from a group of clustered Finders.

## Defense against fraudulent RID Messages

The strongest defense against fraudulent RID messages is to focus on {{DRIP-AUTH}} conforming messages.  Unless this behavior is mandated, an SDSP will have to use assorted algorithms to isolate messages of questionable content.

# Crowd Sourced RID Protocol

~~~~
+--------+                 +------+                 +-----+
| Finder o---------------->o SDSP o<----------------o USS |
+--------+     HTTPS,      +--o---+   Network RID   +-----+
               UDP, HIP,      :
               DTLS           :
                              : Network RID
                              v
                       +------o------+
                       | UTM Clients |
                       +-------------+
~~~~
{: #fig-csrid-protocol title="Protocol Overview"}

This document will focus on the general protocol specification between the Finder and the SDSP. Transport specification and use is provided in {{transports}}. A normative appendix ({{network-rid}}) provides background to Network RID. Another normative appendix ({{cddl-definitions}}) provides all the CDDL models for CS-RID including one for {{F3411}} data.

For all data models CBOR {{RFC7049}} MUST be used for encoding. JSON MAY be supported but its definition is out of scope for this document.

## Detection & Report Models {#csrid-reports}

The CS-RID model is for Finders to send "batch reports" to one or more SDSPs they have a relationship with. This relationship can be highly anonymous with little prior knowledge of the Finder to very well defined and pre-established.

{{fig-csrid-report}} is the report object, defined in CDDL, that is translated and adapted depending on the specific transport. It carries a batch of detections (up to a max of 10), the CDDL definition of which is shown in {{fig-csrid-detection}}. Discussion on the optional fields are found in {{special-fields}}.

~~~~
detection-tag = #6.xxx(detection)
detection = {
  timestamp: time,
  ? position: #6.103(array),
  ? radius: float,  ; meters
  interface: [+ i-face],
  data: bstr / #6.xxx(astm-message) / #6.xxx(uas-data)
}

i-face = (bcast-type, mac-addr)
bcast-type = 0..3 ; BLE Legacy, BLE Long Range, Wi-Fi NAN, 802.11 Beacon
mac-addr = #6.48(bstr)
~~~~
{: #fig-csrid-detection title="Detection CDDL"}

~~~~
ufr-tag = #6.xxx(ufr)
ufr = {
  timestamp: time,
  ? priority: uint .size(2),  ; For HIP/DTLS
  ? track_id: uint .size(2),  ; For HIP/DTLS, 0=Mixed Detections
  ? position: #6.103,
  ? radius: float,  ; meters
  detection_count: 1..10,
  detections: [+ #6.xxx(detection)],
}
~~~~
{: #fig-csrid-report title="Unsigned Report CDDL"}

### Special Fields

The `position` and `radius` fields of both {{fig-csrid-detection}} and {{fig-csrid-report}} are OPTIONAL. If multiple sets of these are present the deepest nested values take precedence. For example if `position` is used in both the Report and Detection structures then the value found in the individual Detections take precedence. This extends to the Endorsement model where the `position` (seen in the model as `#6.103`) and `radius` are optionally included as part of the Endorsement scope.

The fields of `priority` and `track_id` are OPTIONAL but MUST be included when they are set from a command. When not present the SDSP MUST assume them to be their default values of 0. The values of these fields a coordinated between the Finder and SDSP using commands. Either party may set these values and SHOULD announce them via a command before using them in report. They MAY be used over other transports and initialized by a Finder but such operation is out of scope for this document.

## Command Models {#csrid-commands}

Some transports give an added benefit of allowing for control operations to be sent from the SDSP to the Finder. Finders MUST NOT send commands to an SDSP. A Finder MAY choose to ignore commands.

~~~~
command-tag = #6.xxx(command)
command = [command-id, $$command-data]

$$command-data //= (#6.103, ? radius,)
$$command-data //= (uas-id / mac-addr, track-id, ? priority,)
$$command-data //= (track-id, priority)
$$command-data //= ({* tstr => any},)  ; parameter update

command-id = uint .size(1)
~~~~
{: #fig-csrid-command title="Command CDDL"}

## HHIT Endorsements for CS-RID {#csrid-endorsement}

Integrity of the report from a Finder is important. When using DETs, the report or command SHOULD be part of an HHIT Endorsement as seen in {{fig-csrid-endorsement}}. The Endorsement MAY be used over transports that inherently provide integrity and other protections (such as HIP or DTLS) though it is NOT RECOMMENDED. The Endorsement Type of `TBD` is reserved for CS-RID Endorsements.

~~~~
; e-type=???
$$scope-ext //= (
  #6.103,
  ? radius: float  ; meters
)
$$evidence //= ([+ #6.xxx(detection) / #6.xxx(ufr) / #6.xxx(command)],)
$$endorser //= (hhit,)
$$signature //= (eddsa25519-sig,)
~~~~
{: #fig-csrid-endorsement title="Endorsement CDDL"}

## Session Security

Both Finder and SDSP SHOULD use EdDSA {{RFC8032}} keypairs as the base for their identities. These identities SHOULD be in the form of registered DRIP Entity Tags {{RFC9374}}. Registration is covered in {{DIME-ARCH}}. An SDSP MAY have its own DRIP Identity Management Entity (DIME) or share one with other entities in UTM.

An SDSP MUST NOT ignore Finders with DETs outside the DIME it is aware of, and SHOULD use {{DIME-ARCH}} to obtain public key information.

ECIES is the preferred method to initialize a session between the Finder and SDSP. The following steps MUST be followed to setup ECIES for CS-RID:

1. Finder uses {{DIME-ARCH}} to obtain SDSP EdDSA key
2. EdDSA keys are converted to X25519 keys per Curve25519 {{RFC7748}} to use in ECIES
3. ECIES can be used with a unique nonce to authenticate each message sent from a Finder to the SDSP
4. ECIES can be used at the start of some period (e.g. day) to establish a shared secret that is then used to authenticate each message sent from a Finder to the SDSP sent during that period
5. HIP {{RFC7401}} can be used to establish a session secret that is then used with ESP {{RFC4303}} to authenticate each message sent from a Finder to the SDSP
6. DTLS {{RFC5238}} can be used to establish a secure connection that is then used to authenticate each message sent from a Finder to the SDSP

# Transports

CS-RID transport from Finder to SDSP can vary from highly unidirectional with no acknowledgements to strong authenticated and encrypted sessions. Some transports, such as HIP and DTLS, MAY support bi-directional communication to enable control operations between the SDSP and Finder.

The section contains a variety of transports that MAY be supported by an SDSP. CoAP is the RECOMMENDED transport.

## CoAP

When using CoAP {{RFC7252}} with UDP, a payload MUST be a CS-RID Endorsement ({{csrid-endorsement}}). If running DTLS {{RFC5238}} the payload MAY be any of the following: CS-RID Endorsement, CS-RID Finder Report/Detection ({{csrid-reports}}) or CS-RID Command ({{csrid-commands}}). DTLS is the RECOMMENDED underlying transport for CoAP and uses a DET as the identity.

A Finder MUST ACK when accepting and RST when ignoring/rejecting a command from an SDSP.

As CoAP is designed with a stateless mapping to HTTP; such proxies are RECOMMENDED for CS-RID to allow as many Finders as possible to provide reports.

## HIP

The use of HIP {{RFC7401}} imposes a strong authentication and Finder onboarding process. It is attractive for well defined deployments of CS-RID, such as being used for area security. A DET MUST be used as the primary identity when using this transport method.

When ESP is not in use the data MUST be a CS-RID Endorsement ({{csrid-endorsement}}). An ESP link MAY any of the following: CS-RID Endorsement, CS-RID Finder Report/Detection ({{csrid-reports}}) or CS-RID Command ({{csrid-commands}}).

The use of HIP as an underlying transport for CoAP is out of scope for this document.

# IANA Considerations

TBD

# Security Considerations

TBD

# Acknowledgments

The Crowd Sourcing idea in this document came from the Apple "Find My Device" presentation at the International Association for Cryptographic Research's Real World Crypto 2020 conference.

--- back

# Network RID Overview {#network-rid}

This appendix is normative and an overview of the Network RID portion of {{F3411}}.

This appendix is intended a guide to the overall object of Network RID and generally how it functions in context with a CS-RID SDSP. Please refer to the actual standard of {{F3411}} for specifics in implementing said protocol.

For CS-RID the goal is for the SDSP to act as both a Network RID Service Provider (SP) and Network RID Display Provider (DP). The endpoints and models MUST follow the specifications for these roles so UTM clients do not need to implement specific endpoints for CS-RID and can instead leverage existing endpoints.

An SDSP SHOULD use Network RID, as it is able, to query a USS for UAS sending telemetry in a given area to integrate into the Broadcast RID it is receiving from Finders. How the SDSP discovers which USS to query is out of scope for this document.

An SDSP MUST provide the Network RID DP interface for clients that wish to subscribe for updates on aircraft in the SDSP aggregated coverage area.

# Additional SDSP Functionality {#sdsp-functions}

This appendix is informative.

## Multilateration

The SDSP can confirm/correct the UA location provided in the Location/Vector message by using multilateration on data provided by at least 3 Finders that reported a specific Location/Vector message (Note that 4 Finders are needed to get altitude sign correctly).  In fact, the SDSP can calculate the UA location from 3 observations of any Broadcast RID message.  This is of particular value if the UA is only within reception range of the Finders for messages other than the Location/Vector message.

This feature is of particular value when the Finders are fixed assets with highly reliable GPS location, around a high value site like an airport or large public venue.

## Finder Map

The Finders are regularly providing their SDSP with their location. With this information, the SDSP can maintain a monitoring map. That is a map of approximate coverage range of their registered and active Finders.

## Managing Finders

Finder density will vary over time and space. For example, sidewalks outside an urban train station can be packed with pedestrians at rush hour, either coming or going to their commute trains.  An SDSP may want to proactively limit the number of active Finders in such situations.

Using the Finder mapping feature, the SDSP can instruct Finders to NOT proxy Broadcast RID messages. These Finders will continue to report their location and through that reporting, the SDSP can instruct them to again take on the proxying role.  For example a Finder moving slowly along with dozens of other slow-moving Finders may be instructed to suspend proxying.  Whereas a fast-moving Finder at the same location (perhaps a connected car or a pedestrian on a bus) would not be asked to suspend proxying as it will soon be out of the congested area.

Such operation SHOULD be using transports such as HIP or DTLS.

# GPS Inaccuracy

This appendix is informative.

Single-band, consumer grade, GPS on small platforms is not accurate, particularly for altitude.  Longitude/latitude measurements can easily be off by 3M based on satellite position and clock accuracy.  Altitude accuracy is reported in product spec sheets and actual tests to be 3x less accurate. Altitude accuracy is hindered by ionosphere activity. In fact, there are studies of ionospheric events (e.g. 2015 St. Patrick's day {{GPS-IONOSPHERE}}) as measured by GPS devices at known locations.  Thus where a UA reports it is rarely accurate, but may be accurate enough to map to visual sightings of single UA.

Smartphones and particularly smartwatches are plagued with the same challenge, though some of these can combine other information like cell tower data to improve location accuracy. FCC E911 accuracy, by FCC rules is NOT available to non-E911 applications due to privacy concerns, but general higher accuracy is found on some smart devices than reported for consumer UA.  The SDSP MAY have information on the Finder location accuracy that it can use in calculating the accuracy of a multilaterated location value.  When the Finders are fixed assets, the SDSP may have very high trust in their location for trusting the multilateration calculation over the UA reported location.

# CDDL Definitions

This appendix is normative.

## F3411 Message Set

~~~~
astm-tag = #6.xxx(astm-message)
astm-message = b-message / mp-message

; Message (m-type)
; Message Pack (0xF)
mp-message = [
  m-counter, m-type, p-ver, 
  m-size, num-messages, [+ b-message]
]

b-message = [m-counter, m-type, p-ver, $$b-data]

; Basic ID (0x0), Location (0x1)
$$b-data //= (uas-type, uas-id-type, uas-id)
$$b-data //= (
  status, height-type, track-direction, horz-spd, 
  vert-spd, lat, lon, geo-alt baro-alt, height, 
  h-acc, v-acc, b-acc, s-acc, t-acc, timemark
)

; Authentication (0x2)
$$b-data //= (page-num, a-type, lpi, length, auth-ts, pg-data)

; Self ID (0x3), System (0x4), Operator ID (0x5)
$$b-data //= (desc-type, desc)
$$b-data //= (op-type, class-type, lat, lon, area-count, 
  area-radius, area-floor, area-ceiling, geo-alt, 
  eu-class, eu-cat, utc-timestamp
)
$$b-data //= (op-id-type, op-id)

; Basic ID (0x0) Fields
uas-type = nibble-field
uas-id-type = nibble-field
uas-id = bstr .size(20)

; Location (0x1) Fields
status = nibble-field
height-type = bool
track-direction = uint
horz-spd = uint .size(1)
vert-spd = uint .size(1)
baro-alt = uint .size(2)
height = uint .size(2)
h-acc = nibble-field
v-acc = nibble-field
b-acc = nibble-field
s-acc = nibble-field
t-acc = nibble-field
timemark = uint .size(2)  ; tenths of seconds since current hour

; Authentication (0x2) Fields
page-num = nibble-field
a-type = nibble-field
lpi = nibble-field
length = uint .size(1)
auth-ts = time  ; converted from ASTM F3411-22a epoch
pg-data = bstr .size(23)
a-data = bstr .size(0..255)
adl = uint .size(1)
add-data = bstr .size(0..255)

; Self ID (0x3) Fields
desc-type = uint .size(1)
desc = tstr .size(23)

; System (0x4) Fields
op-type = 0..3
class-type = 0..8
area-count = 1..255
area-radius = float
area-floor = float
area-ceiling = float
eu-class = nibble-field
eu-cat = nibble-field
utc-timestamp = time  ; converted from ASTM F3411-22a epoch

; Operator ID (0x5) Fields
op-id-type = uint .size(1)
op-id = tstr .size(20)

; Message Pack (0xF) Fields
m-size = uint .size(1)  ; always set to decimal 25
num-messages = 1..9

; Other fields
m-counter = uint .size(1)
m-type = nibble-field
p-ver = nibble-field
lat = uint .size(4)      ; scaled by 10^7
lon = uint .size(4)      ; scaled by 10^7
geo-alt = uint .size(2)  ; WGS84-HAE in meters
nibble-field = 0..15
~~~~

## UAS Data

~~~~
uas-tag = #6.xxx(uas-data)
uas-data = {
? uas_type: uas-type,
? uas_id_type: uas-id-type,
? uas_id: uas-id,
? ua_status: status,
? track_direction: track-direction,
? ua_geo_position: #6.103(array)
? ua_baro_altitude: baro-alt,
? ua_height: height,
? vertical_speed: vert-spd,
? horizontal_speed: horz-spd,
? auth_type: a-type,
? auth_data: a-data,
? additional_data: add-data,
? self_id: desc,
? ua_classification: class-type
? operator_type: op-type,
? operator_geo_position: #6.103(array)
? area_count: area-count,
? area_radius: area-radius,
? area_floor: area-floor,
? area_ceiling: area-ceiling,
? eu_class: eu-class,
? eu_category: eu-cat,
? system_timestamp: utc-timestamp,
? operator_id: op-id
}
~~~~

## Complete CDDL

~~~~
$$scope-ext //= (
  #6.103,
  ? radius: float  ; meters
)
$$evidence //= ([+ #6.xxx(detection) / #6.xxx(ufr) / #6.xxx(command)],)
$$endorser //= (hhit,)
$$signature //= (eddsa25519-sig,)

command-tag = #6.xxx(command)
command = [command-id, $$command-data]

$$command-data //= (#6.103, ? radius,)
$$command-data //= (uas-id / mac-addr, track-id, ? priority,)
$$command-data //= (track-id, priority)
$$command-data //= ({* tstr => any},)  ; parameter update


ufr-tag = #6.xxx(ufr)
ufr = {
  timestamp: time,
  ? priority: uint .size(2),  ; For HIP/DTLS
  ? track_id: uint .size(2),  ; For HIP/DTLS, 0=Mixed Detections
  ? position: #6.103,
  ? radius: float,  ; meters
  detection_count: 1..10,
  detections: [+ #6.xxx(detection)],
}

detection-tag = #6.xxx(detection)
detection = {
  timestamp: time,
  ? position: #6.103(array),
  ? radius: float,  ; meters
  interface: [+ i-face],
  data: bstr / #6.xxx(astm-message) / #6.xxx(uas-data)
}

uas-tag = #6.xxx(uas-data)
uas-data = {
? uas_type: uas-type,
? uas_id_type: uas-id-type,
? uas_id: uas-id,
? ua_status: status,
? track_direction: track-direction,
? ua_geo_position: #6.103(array)
? ua_baro_altitude: baro-alt,
? ua_height: height,
? vertical_speed: vert-spd,
? horizontal_speed: horz-spd,
? auth_type: a-type,
? auth_data: a-data,
? additional_data: add-data,
? self_id: desc,
? ua_classification: class-type
? operator_type: op-type,
? operator_geo_position: #6.103(array)
? area_count: area-count,
? area_radius: area-radius,
? area_floor: area-floor,
? area_ceiling: area-ceiling,
? eu_class: eu-class,
? eu_category: eu-cat,
? system_timestamp: utc-timestamp,
? operator_id: op-id
}

astm-tag = #6.xxx(astm-message)
astm-message = b-message / mp-message

; Message (m-type)
; Message Pack (0xF)
mp-message = [
  m-counter, m-type, p-ver, 
  m-size, num-messages, [+ b-message]
]

b-message = [m-counter, m-type, p-ver, $$b-data]

; Basic ID (0x0), Location (0x1)
$$b-data //= (uas-type, uas-id-type, uas-id)
$$b-data //= (
  status, height-type, track-direction, horz-spd, 
  vert-spd, lat, lon, geo-alt baro-alt, height, 
  h-acc, v-acc, b-acc, s-acc, t-acc, timemark
)

; Authentication (0x2)
$$b-data //= (page-num, a-type, lpi, length, auth-ts, pg-data)

; Self ID (0x3), System (0x4), Operator ID (0x5)
$$b-data //= (desc-type, desc)
$$b-data //= (op-type, class-type, lat, lon, area-count, 
  area-radius, area-floor, area-ceiling, geo-alt, 
  eu-class, eu-cat, utc-timestamp
)
$$b-data //= (op-id-type, op-id)

; Basic ID (0x0) Fields
uas-type = nibble-field
uas-id-type = nibble-field
uas-id = bstr .size(20)

; Location (0x1) Fields
status = nibble-field
height-type = bool
track-direction = uint
horz-spd = uint .size(1)
vert-spd = uint .size(1)
baro-alt = uint .size(2)
height = uint .size(2)
h-acc = nibble-field
v-acc = nibble-field
b-acc = nibble-field
s-acc = nibble-field
t-acc = nibble-field
timemark = uint .size(2)  ; tenths of seconds since current hour

; Authentication (0x2) Fields
page-num = nibble-field
a-type = nibble-field
lpi = nibble-field
length = uint .size(1)
auth-ts = time  ; converted from ASTM F3411-22a epoch
pg-data = bstr .size(23)
a-data = bstr .size(0..255)
adl = uint .size(1)
add-data = bstr .size(0..255)

; Self ID (0x3) Fields
desc-type = uint .size(1)
desc = tstr .size(23)

; System (0x4) Fields
op-type = 0..3
class-type = 0..8
area-count = 1..255
area-radius = float
area-floor = float
area-ceiling = float
eu-class = nibble-field
eu-cat = nibble-field
utc-timestamp = time  ; converted from ASTM F3411-22a epoch

; Operator ID (0x5) Fields
op-id-type = uint .size(1)
op-id = tstr .size(20)

; Message Pack (0xF) Fields
m-size = uint .size(1)  ; always set to decimal 25
num-messages = 1..9

; Other fields
m-counter = uint .size(1)
m-type = nibble-field
p-ver = nibble-field
lat = uint .size(4)      ; scaled by 10^7
lon = uint .size(4)      ; scaled by 10^7
geo-alt = uint .size(2)  ; WGS84-HAE in meters
nibble-field = 0..15
i-face = (bcast-type, mac-addr)
bcast-type = 0..3 ; BLE Legacy, BLE Long Range, Wi-Fi NAN, 802.11 Beacon
mac-addr = #6.48(bstr)
command-id = uint .size(1)
~~~~
