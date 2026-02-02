# Docker-based Snort 2 NIDS Lab

This project builds a modular Snort 2 IDS lab with dedicated containers for a sensor, attacker, protected service, and log viewer. All configuration, rules, and logs are mounted into the Snort container so you can iterate on rules without rebuilding the image.

## Directory Tree

```text
.
├── README.md
├── attacker/
│   ├── Dockerfile
│   └── scripts/
│       ├── dos/
│       │   ├── icmp_flood.sh
│       │   └── README.md
│       ├── network-scan/
│       │   ├── nmap_syn_scan.sh
│       │   └── README.md
│       └── unauthorized/
│           ├── access_admin.sh
│           └── README.md
├── deploy/
│   └── docker-compose.yml
├── docs/
│   └── screenshots/
│       └── README.md
├── elasticsearch/
│   └── config/
├── kibana/
│   ├── config/
│   │   └── kibana.yml
│   ├── saved_objects/
│   │   └── snort.ndjson
│   └── scripts/
│       └── setup_kibana.sh
├── log-viewer/
│   └── Dockerfile
├── logstash/
│   └── pipeline/
│       └── snort.conf
├── snort/
│   ├── Dockerfile
│   ├── config/
│   │   └── snort.conf
│   ├── logs/
│   └── rules/
│       ├── dos.rules
│       ├── scan.rules
│       └── unauthorized.rules
└── target/
    ├── Dockerfile
    └── index.html
```

## Rule-to-Attack Mapping

| Rule File | Attack Category | Script | SID | Message |
| --- | --- | --- | --- | --- |
| `snort/rules/scan.rules` | Network scanning | `attacker/scripts/network-scan/nmap_syn_scan.sh` | 1000001 | NIDS: TCP SYN scan activity |
| `snort/rules/dos.rules` | Denial-of-Service traffic | `attacker/scripts/dos/icmp_flood.sh` | 1000002 | NIDS: ICMP echo flood |
| `snort/rules/unauthorized.rules` | Unauthorized access | `attacker/scripts/unauthorized/access_admin.sh` | 1000003 | NIDS: Unauthorized admin access attempt |

## Usage (Docker Compose)

All containers share the `nids-net` Docker bridge network. The Snort container runs in IDS mode and shares the protected service network namespace so it can observe attacker-to-target traffic on the bridge.

1. Start the lab:

   ```bash
   cd deploy
   docker compose up --build
   ```

2. In a separate terminal, run attacks from the attacker container:

   ```bash
   docker compose exec attacker /attacks/scripts/network-scan/nmap_syn_scan.sh protected 1-100
   docker compose exec attacker /attacks/scripts/dos/icmp_flood.sh protected
   docker compose exec attacker /attacks/scripts/unauthorized/access_admin.sh protected 8080
   ```

3. View alerts:

   ```bash
   docker compose logs -f log-viewer
   ```

Alert output uses Snort's fast format and includes the SID, message, timestamp, and source/destination IPs.

4. Open Kibana:

   ```bash
   open http://localhost:5601
   ```

   The `snort-alerts-*` data view and the **Snort Alerts Overview** dashboard are imported automatically by the `kibana-setup` service.

## Log Flow (Snort → Logstash → Elasticsearch → Kibana)

1. Snort writes fast-format alerts to `snort/logs/alert.fast`.
2. Logstash tails `alert.fast`, parses the alert fields, and enriches with `attack_type`.
3. Logstash sends structured JSON to Elasticsearch with daily indices `snort-alerts-YYYY.MM.dd`.
4. Kibana connects to Elasticsearch, uses the `snort-alerts-*` data view, and loads the **Snort Alerts Overview** dashboard for filtering and analysis.

### Parsed Alert Fields

Logstash emits structured JSON with the fields required for analysis:

- `@timestamp`
- `rule_sid`
- `alert_message`
- `src_ip`
- `dest_ip`
- `protocol`
- `src_port`
- `dest_port`
- `attack_type`

## Kibana Index Pattern & Dashboard

- Data view ID: `snort-alerts` (pattern: `snort-alerts-*`)
- Time field: `@timestamp`
- Dashboard: **Snort Alerts Overview**
- Filter controls: Rule SID, Source IP, Destination IP, Attack Type

## Screenshots

Store Kibana dashboard and Discover screenshots under `docs/screenshots/` after running the lab.

## Troubleshooting

- **Kibana connection refused**: ensure Elasticsearch is healthy and `kibana` depends on `elasticsearch`.
- **Missing data view**: re-run `kibana-setup` or import `kibana/saved_objects/snort.ndjson`.
- **Incorrect timestamps**: verify Snort is writing timestamps and Logstash date parsing in `logstash/pipeline/snort.conf`.

## Snort Configuration Notes

- Configuration is externalized in `snort/config/snort.conf` and mounted into the Snort container.
- Each rule is stored in its own `.rules` file under `snort/rules/` and explicitly included by `snort.conf`.
- Logs are written to `snort/logs/` and mounted so they persist outside the container.

## References

- Snort official documentation: https://www.snort.org
