# 2. Product Ecosystem

## Foundation

OffGridOS is a family of interoperable products rather than one monolithic application. Each product should work locally, expose documented APIs, and fail gracefully when optional services are unavailable.

## Product lines

| Line | Purpose |
|---|---|
| Media Server | Local media, files, knowledge, maps, and household services |
| Energy | Solar, battery, load, temperature, and power-budget monitoring |
| Local AI | Private assistants, search, summarization, and automation on local hardware |
| Communications | Local messaging, mesh networking, radio gateways, and emergency channels |
| Atlas | Trusted locations, services, access rules, safety information, and community maps |
| Knowledge | Offline manuals, courses, repair information, and locally authored guides |
| Agriculture and water | Monitoring and workflow support for food, soil, water, and resource systems |
| Marketplace | Services, goods, installations, equipment, and transparent participation credits |

## Common platform capabilities

Identity, permissions, local service discovery, encrypted backups, update channels, event logging, resource monitoring, API versioning, and exportable data are shared capabilities. Product modules must remain independently removable.

## Expansion rule

New modules should first be useful on one local node. Regional or cloud synchronization is an optional enhancement, never a prerequisite for basic operation.
