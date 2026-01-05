# Trinity Pool & Explorer - Visual Overview

```
┌───────────────────────────────────────────────────────────────────────┐
│                     TRINITY MINING POOL SYSTEM                         │
└───────────────────────────────────────────────────────────────────────┘

                            Users & Interactions
                                    │
        ┌──────────────┬────────────┼────────────┬──────────────┐
        │              │            │            │              │
        ▼              ▼            ▼            ▼              ▼
   Miners         Web Users     Explorer      Admin       API Clients
  (cgminer)      (Browsers)    Searches    (Dashboard)   (Scripts)
        │              │            │            │              │
        └──────────────┴────────────┴────────────┴──────────────┘
                                    │
                                    ▼
        ┌───────────────────────────────────────────────────────┐
        │              WEB INTERFACE (Port 80/8080)              │
        │  ┌─────────────────────────────────────────────────┐  │
        │  │         Nginx Reverse Proxy (Port 80)           │  │
        │  └────────────────────┬────────────────────────────┘  │
        │                       ▼                                │
        │  ┌─────────────────────────────────────────────────┐  │
        │  │      Flask Application (app.py - Port 8080)     │  │
        │  │                                                  │  │
        │  │  ┌────────────┐  ┌────────────┐  ┌──────────┐  │  │
        │  │  │   Public   │  │  Explorer  │  │  Admin   │  │  │
        │  │  │   Pages    │  │   Pages    │  │  Panel   │  │  │
        │  │  └────────────┘  └────────────┘  └──────────┘  │  │
        │  └─────────────────────────────────────────────────┘  │
        └────────────────┬──────────────┬───────────────────────┘
                         │              │
                ┌────────┴────┐    ┌────┴────────┐
                ▼             ▼    ▼             ▼
        ┌────────────┐  ┌────────────┐    ┌──────────────┐
        │ Pool Server│  │  Database  │    │ Trinity RPC  │
        │(Port 3333) │  │  (SQLite/  │    │(Port 62620)  │
        │            │  │ PostgreSQL)│    │              │
        └─────┬──────┘  └─────┬──────┘    └──────┬───────┘
              │               │                   │
              ▼               ▼                   ▼
        ┌──────────────────────────────────────────────┐
        │         Core Components & Data Flow          │
        │                                              │
        │  Share         Worker        Payment         │
        │  Validation ──▶ Tracking ──▶ Processing    │
        │     │              │             │           │
        │     ▼              ▼             ▼           │
        │  Database ←──── Stats ────▶ Blockchain     │
        └──────────────────────────────────────────────┘


┌───────────────────────────────────────────────────────────────────────┐
│                         DATA FLOW DIAGRAM                              │
└───────────────────────────────────────────────────────────────────────┘

  1. MINING FLOW
     Miner ──[getwork request]──▶ Pool Server ──[new work]──▶ Miner
                                        │
                                        ├──▶ Trinity RPC (get block template)
                                        │
     Miner ──[submit share]─────▶ Pool Server
                                        │
                                        ├──▶ Validate Share
                                        ├──▶ Update Worker Stats
                                        ├──▶ Store in Database
                                        │
                                        └──[if block found]──▶ Process Payments

  2. PAYMENT FLOW
     Block Found ──▶ Calculate Shares ──▶ Proportional Distribution
                          │                       │
                          ▼                       ▼
                   Get all shares         Calculate amounts
                   since last block       for each worker
                          │                       │
                          ▼                       ▼
                   Apply pool fee          Update pending balances
                          │                       │
                          └───────────────────────┘
                                    │
                                    ▼
                          Payments >= Threshold? ──Yes──▶ Send Batch Payment
                                    │                           │
                                    No                          ▼
                                    │                    Mark as Confirmed
                                    ▼                           │
                            Keep Pending                        ▼
                                                         Update Worker Stats

  3. WEB INTERFACE FLOW
     User Request ──▶ Nginx ──▶ Flask App
                                    │
                                    ├──[homepage]────▶ Get Pool Stats
                                    │                       │
                                    │                       ├─▶ Database
                                    │                       └─▶ Trinity RPC
                                    │
                                    ├──[explorer]────▶ Query Blocks
                                    │                       │
                                    │                       └─▶ Database
                                    │
                                    ├──[worker stats]─▶ Query Worker
                                    │                       │
                                    │                       └─▶ Database
                                    │
                                    └──[admin]────────▶ Authenticate
                                                           │
                                                           ├─▶ Dashboard
                                                           ├─▶ Settings
                                                           └─▶ Management


┌───────────────────────────────────────────────────────────────────────┐
│                        DATABASE SCHEMA                                 │
└───────────────────────────────────────────────────────────────────────┘

  ┌─────────────┐
  │   blocks    │
  ├─────────────┤
  │ id (PK)     │
  │ height      │◀──────────┐
  │ hash        │           │
  │ prev_hash   │           │
  │ timestamp   │           │
  │ difficulty  │           │
  │ reward      │           │
  │ finder      │◀────┐     │
  │ algo        │     │     │
  └─────────────┘     │     │
                      │     │
  ┌─────────────┐     │     │
  │   workers   │     │     │
  ├─────────────┤     │     │
  │ id (PK)     │─────┘     │
  │ address     │           │
  │ hashrate    │           │
  │ total_shares│           │
  │ pending_bal │           │
  │ total_paid  │           │
  │ last_seen   │           │
  └──────┬──────┘           │
         │                  │
         │                  │
  ┌──────▼──────┐    ┌──────▼──────┐
  │   shares    │    │  payments   │
  ├─────────────┤    ├─────────────┤
  │ id (PK)     │    │ id (PK)     │
  │ worker_id FK│    │ worker_id FK│
  │ timestamp   │    │ block_height│
  │ difficulty  │    │ amount      │
  │ valid       │    │ txid        │
  │ block_height│    │ status      │
  └─────────────┘    └─────────────┘


┌───────────────────────────────────────────────────────────────────────┐
│                     DEPLOYMENT ARCHITECTURE                            │
└───────────────────────────────────────────────────────────────────────┘

  Google Cloud VM (Ubuntu 20.04)
  ┌────────────────────────────────────────────────────────────┐
  │                                                            │
  │  ┌──────────────────────────────────────────────────┐    │
  │  │           Firewall (ufw/GCP)                     │    │
  │  │  Port 80   (HTTP)         ────▶ Open            │    │
  │  │  Port 443  (HTTPS)        ────▶ Open (optional) │    │
  │  │  Port 3333 (Mining)       ────▶ Open            │    │
  │  │  Port 62620 (RPC)         ────▶ Closed          │    │
  │  │  Port 22   (SSH)          ────▶ Admin only      │    │
  │  └──────────────────────────────────────────────────┘    │
  │                                                            │
  │  ┌──────────────────────────────────────────────────┐    │
  │  │              systemd Services                     │    │
  │  │                                                   │    │
  │  │  trinity-pool.service ────▶ Flask App            │    │
  │  │  nginx.service        ────▶ Web Server           │    │
  │  │  trinityd             ────▶ Daemon (manual)      │    │
  │  └──────────────────────────────────────────────────┘    │
  │                                                            │
  │  File System:                                             │
  │  /opt/trinity-pool/      - Application                    │
  │  /var/log/nginx/         - Web server logs                │
  │  ~/.trinity/             - Daemon config & data           │
  │                                                            │
  └────────────────────────────────────────────────────────────┘


┌───────────────────────────────────────────────────────────────────────┐
│                        FEATURE MATRIX                                  │
└───────────────────────────────────────────────────────────────────────┘

  ╔═══════════════════════╦═════════╦══════════════════════════════════╗
  ║ Component             ║ Status  ║ Description                      ║
  ╠═══════════════════════╬═════════╬══════════════════════════════════╣
  ║ Mining Pool           ║   ✅    ║ Full getwork protocol support    ║
  ║ Share Validation      ║   ✅    ║ Real-time validation             ║
  ║ Worker Management     ║   ✅    ║ Auto registration & tracking     ║
  ║ Payment System        ║   ✅    ║ Automatic PROP distribution      ║
  ║ Block Explorer        ║   ✅    ║ Web-based blockchain browser     ║
  ║ Search Function       ║   ✅    ║ Blocks, addresses, transactions  ║
  ║ Admin Panel           ║   ✅    ║ Full management interface        ║
  ║ Authentication        ║   ✅    ║ Secure login system              ║
  ║ API Endpoints         ║   ✅    ║ RESTful API for stats            ║
  ║ Responsive Design     ║   ✅    ║ Mobile-friendly interface        ║
  ║ Real-time Stats       ║   ✅    ║ Auto-updating statistics         ║
  ║ Database Support      ║   ✅    ║ SQLite & PostgreSQL              ║
  ║ Nginx Integration     ║   ✅    ║ Reverse proxy configuration      ║
  ║ Systemd Service       ║   ✅    ║ Auto-start & management          ║
  ║ Documentation         ║   ✅    ║ Comprehensive guides             ║
  ║ Deployment Scripts    ║   ✅    ║ One-command setup                ║
  ╚═══════════════════════╩═════════╩══════════════════════════════════╝


┌───────────────────────────────────────────────────────────────────────┐
│                    FILES STRUCTURE OVERVIEW                            │
└───────────────────────────────────────────────────────────────────────┘

  pool-explorer/
  │
  ├── Core Application
  │   ├── app.py               (Flask web application)
  │   ├── models.py            (Database models)
  │   ├── pool_server.py       (Mining pool logic)
  │   └── rpc_client.py        (Trinity RPC interface)
  │
  ├── Configuration
  │   └── config/
  │       ├── __init__.py
  │       └── config.py        (Settings & environment vars)
  │
  ├── Web Templates
  │   └── templates/
  │       ├── base.html        (Base template)
  │       ├── index.html       (Homepage)
  │       ├── how_to_mine.html (Mining guide)
  │       ├── blocks.html      (Block list)
  │       ├── block_detail.html(Block details)
  │       ├── worker_stats.html(Worker statistics)
  │       ├── admin_*.html     (Admin panel pages)
  │       └── error pages      (404, 500)
  │
  ├── Deployment
  │   ├── setup.sh            (Production deployment)
  │   ├── dev-setup.sh        (Development setup)
  │   └── requirements.txt    (Python dependencies)
  │
  └── Documentation
      ├── README.md           (Comprehensive guide)
      ├── QUICKSTART.md       (Quick start guide)
      └── MINING-GUIDE.md     (Miner configuration)

  Repository Root:
  ├── POOL-DEPLOYMENT.md      (Main deployment guide)
  └── POOL-IMPLEMENTATION.md  (Technical overview)


┌───────────────────────────────────────────────────────────────────────┐
│                         STATISTICS                                     │
└───────────────────────────────────────────────────────────────────────┘

  Code Statistics:
  • Total Files Created:    31
  • Total Lines of Code:    3,578+
  • Python Modules:         5
  • HTML Templates:         14
  • Documentation Files:    5
  • Shell Scripts:          2

  Components:
  • Web Routes:            15+
  • Database Models:       7
  • Admin Pages:           6
  • Public Pages:          5
  • API Endpoints:         3

  Features Implemented:
  • Mining protocols:      getwork
  • Algorithms supported:  sha256d, scrypt, groestl
  • Payment method:        Proportional (PROP)
  • Authentication:        Session-based
  • Database support:      SQLite, PostgreSQL
```
