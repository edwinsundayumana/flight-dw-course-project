# Flight Data Warehouse — Course Project

Data Warehousing course project: designing and building a star-schema data warehouse for flight
segment ("frequent-flyer") data, with an OLAP cube and MDX-based analysis, built in Microsoft SQL
Server / SSAS.

## Project roadmap

| Phase | Description | Status |
|---|---|---|
| 1 | Preprocess `FactAirticket` to satisfy dataset requirements (airport diversity, transit stopovers, airline diversity, plane assignment, passenger/date spread) | ✅ Complete |
| 2 | Star schema design — formalize dimension/fact relationships and hierarchies | ✅ Complete |
| 3 | Build the data warehouse in SQL Server (tables, load, relationships) | ✅ Complete (achieved as part of Phases 1–2) |
| 4 | Build the OLAP cube in SSAS | ⬜ Not started |
| 5 | Write 21+ MDX queries (7+ OLAP operation types × 3 examples each) | ⬜ Not started |
| 6 | Final report | ⬜ Not started |

## Repository structure

```
├── queries/     SQL scripts, in run order, with their own README
├── csv/         Exported snapshots of tables at key milestones, with their own README
├── screenshots/   Visual evidence captured throughout the project — diagrams, query results, SSMS/SSAS screen
└── README.md    This file
```

More folders (e.g. `mdx/`, `report/`, `screenshots/`) will be added as later phases begin.

## Database overview

Database name: `FlightDW`

**Fact table:** `FactAirticket` (600 rows)
- Primary key: `FlightFactID`
- 11 foreign key relationships to the dimensions below

**Dimension tables:**
- `DimAirport` (184 airports) — referenced 3 times by the fact table (role-playing dimension: Departure, Transit, Landing)
- `DimAirlines` (18 airlines) — referenced directly via `AirlinesID`
- `DimPlane` (18 aircraft)
- `DimDateRange` (365 days, calendar year 2021) — referenced twice (Departure date, Arrival date)
- `DimPriceRange` (30 price bands)
- `DimSeat` (1,353 individual seats across F/C/Y classes)
- `DimPassenger` (62,044 passengers)
- `DimTicket` (568,942 flight records — 568,917 original + 25 synthetic, see `queries/README.md`)

## Star schema diagram (conceptual)

```
                    DimDateRange (x2: Departure/Arrival)
                            |
DimPassenger ---      FactAirticket      --- DimAirlines
                            |
    DimAirport (x3:   DimPlane, DimSeat,
  Dep/Transit/Land)     DimPriceRange, DimTicket
```

Every relationship above is enforced with a real SQL Server foreign key constraint (11 total) —
not just correct by coincidence.

## Environment

- Microsoft SQL Server 2025 / SSMS for the relational database
- SQL Server Data Tools (SSDT) + SSAS for the OLAP cube (Phase 4 onward)

## AUTHOR
EDWIN SUNDAY UMANA