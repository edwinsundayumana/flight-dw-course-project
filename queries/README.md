# Queries

SQL scripts used to build and preprocess the `FlightDW` data warehouse, in the order they were run.

## Phase 1 — Preprocessing `FactAirticket`

| Script | Purpose |
|---|---|
| `00_fix_rate_datatype.sql` | Fixes the `Rate` column, which was imported as an imprecise `real` type, causing floating-point display errors. Converted to `decimal(3,2)`. |
| `01_fix_planeid_roundrobin.sql` | Fills all 529 blank `PlaneID` values using a balanced round-robin across all 18 aircraft in `DimPlane`. |
| `02_fix_airports_departure_landing.sql` | Expands `Departure_ariportID` / `Landing_ariportID` from 2 airports to 30, guaranteeing departure ≠ landing on every row via a mathematical offset. |
| `03_fix_transit_airports.sql` | Adds a stopover/transit airport to 25 of the 600 rows (assignment-specified minimum: 20), guaranteed distinct from both departure and landing. |
| `04_insert_synthetic_airline_tickets.sql` | Adds 25 clearly-synthetic ticket records for 5 airlines that exist in `DimAirlines` but had zero real flights logged in `DimTicket`. |
| `05_reassign_tickets_for_airline_diversity.sql` | Reassigns `TicketID` across all fact rows so that ≥10 distinct airlines are represented (achieved: 12). |
| `06_verification_all_requirements.sql` | Final consolidated check confirming every Phase 1 requirement is satisfied. |

## Phase 2 — Star Schema Formalization

| Script | Purpose |
|---|---|
| `07_add_flightfactid_primary_key.sql` | Adds `FlightFactID`, a proper surrogate primary key (the fact table previously had none). |
| `08_add_direct_airlinesid_link.sql` | Adds a direct `AirlinesID` column to the fact table, closing a two-hop join (previously required `FactAirticket → DimTicket → DimAirlines`). |
| `09_fix_orphaned_passenger_ids.sql` | Fixes 15 rows referencing `PassengerID` values that don't exist in `DimPassenger` — a pre-existing data issue in the original source file, only discovered once a real foreign key constraint was attempted. |
| `10_add_remaining_foreign_keys.sql` | Declares the remaining 9 foreign key relationships (3 airport roles, both dates, ticket, plane, cabin, price range), completing all 11 formal relationships in the star schema. |

## Phase 4 — OLAP Cube (SSAS)

| Script | Purpose |
|---|---|
| `11_grant_ssas_service_account_access.sql` | Grants the Analysis Services service account read access to `FlightDW`, fixing a cube deployment failure caused by an unsupported impersonation mode during processing. See `cube/README.md` for full context. |

## Requirements checklist (from assignment spec)

- [x] ≥20 distinct departure airports
- [x] ≥20 distinct landing airports (and departure ≠ landing per row)
- [x] ≥20 of 600 rows include a transit/stopover airport
- [x] ≥50 distinct passengers
- [x] ≥10 distinct airlines
- [x] Flight dates span ~6 months
- [x] `PlaneID` never blank, not all identical
- [x] `CabinID` never blank, not all identical (already satisfied by source data)
- [x] Fact table has a formal primary key
- [x] All 11 dimension relationships enforced as real foreign key constraints
- [x] OLAP cube built, deployed, and processed successfully

## Notes / known simplifications

- 11 of the 18 airlines in `DimAirlines` have zero real flights in the 568,917-row `DimTicket` table (a limitation of the source data, not an error in our process). We manufactured a small number of synthetic ticket rows for 5 of them to clear the ≥10 airline diversity requirement — see script `04`.
- Ticket `departureTime`/`arrivalTime` values are not reconciled against the fact table's `DepartureDateID`/`ArrivalDateID` — these are independent dimensions in the current design. Documented as a known simplification.
- `DimPassenger`'s ID sequence has 944 gaps (1–62988 range, only 62044 rows) — a pre-existing characteristic of the source file. 15 fact rows happened to reference gap values; fixed in script `09`.
- `DimPlane`'s ID sequence has 1 gap (missing ID 4) — did not cause any issues since our `PlaneID` assignment logic always draws from real, existing `DimPlane` IDs.
- The SSAS instance used for the cube (`EDWIN\SSAS_EVAL`) is a separate named instance from the main Database Engine (`EDWIN`), installed specifically to work around a Microsoft edition bug — see `cube/README.md` for details.