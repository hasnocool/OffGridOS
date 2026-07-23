# 9. Security, Privacy, and Equipment Safety

## Security baseline

Unique credentials, least privilege, encrypted management, firewall defaults, signed updates, backup encryption, dependency review, audit logs, and a documented recovery account are mandatory.

## Privacy

Collect the minimum data required. Local operation must not depend on analytics. Users control synchronization, retention, exports, deletion, and sharing. Location and reputation data require special protection because misuse can create physical risk.

## Threat model

Consider lost devices, malicious local users, compromised clients, hostile network traffic, supply-chain compromise, fraudulent listings, service outages, and accidental disclosure. Threat assumptions must be revisited as Atlas and mesh features expand.

## Equipment safety

OffGridOS may monitor energy and environmental systems, but software must not be treated as a substitute for electrical, structural, fire, battery, radio, or building-code expertise. Safety-critical control requires independent limits, fusing, physical disconnects, manufacturer specifications, and qualified installation.

## Incident response

Provide a local emergency stop or isolation procedure where applicable, preserve relevant logs without collecting unnecessary personal data, rotate credentials, restore from known-good backups, and publish concise incident guidance.
