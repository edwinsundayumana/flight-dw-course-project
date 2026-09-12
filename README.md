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
| 4 | Build the OLAP cube in SSAS | ✅ Complete |
| 5 | Write 21+ MDX queries (7 OLAP operation types × 3 examples each) | ✅ Complete (21/21) |
| 6 | Final report | ✅ Completed request via email: edwinsunday144@gmial.com cc umanaedwin247@gmail.com|


## Repository structure
```
├── queries/       SQL scripts, in run order, with their own README
├── csv/           Exported snapshots of tables at key milestones, with their own README
├── cube/          Visual Studio Analysis Services (SSAS) project, with its own README
├── mdx/           21 MDX queries across 7 OLAP operations, with results, with their own README
├── screenshots/   Visual evidence (diagrams, etc.), with its own README
└── README.md      This file
```

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

## OLAP cube overview

Server: `EDWIN\SSAS_EVAL` (SQL Server Analysis Services, Evaluation edition, Multidimensional
mode — see `cube/README.md` for why this is a separate named instance from the main Database
Engine, and the story behind why)

Cube: `FlightAirticketCube`
- Measures: `Mileage`, `Price`, `Rate`, `Fact Airticket Count`
- 11 dimensions, matching the star schema's 11 foreign key relationships exactly

## MDX analysis overview

21 queries across 7 OLAP operations (Slice, Dice, Drill Down, Roll Up, Rank, Moving Average,
Top N), each with a real business justification, tested MDX, and exported results. See
`mdx/README.md` for the full list and a detailed log of MDX-specific problems encountered and
solved along the way (naming/hierarchy pitfalls, NULL-sorting behavior, tie-breaking, etc.) —
directly useful source material for the report's "problems and solutions" section.


## Environment

- Microsoft SQL Server 2025 / SSMS for the relational database (instance: `EDWIN`)
- Visual Studio 2026 + SQL Server Data Tools + Microsoft Analysis Services Projects extension,
  for building the OLAP cube
- SQL Server Analysis Services, Evaluation edition (instance: `EDWIN\SSAS_EVAL`), for hosting
  and processing the cube


## AUTHOR
EDWIN SUNDAY UMANA