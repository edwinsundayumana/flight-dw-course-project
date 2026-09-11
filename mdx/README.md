# MDX Queries (Phase 5 — OLAP Analysis)

21+ MDX queries demonstrating 7+ OLAP operation types (3 examples each), run against
`FlightAirticketCube` on `EDWIN\SSAS_EVAL`.

## Naming convention

`<operation>_<number>_<short description>.mdx`, with a matching `<same name>_result.txt`
holding that query's exported result grid.

## Progress

| # | Operation | File | Business question | Status |
|---|---|---|---|---|
| 1 | Slice | `slice_01_price_by_airline_march2021.mdx` | Total ticket revenue by airline, for March 2021 only. Helps identify which airlines were strongest in a specific period (e.g. seasonal/holiday performance). | ✅ Done |
| 2 | Slice | `slice_02_mileage_by_airport_firstclass.mdx` | Total mileage flown by departure airport, for First Class passengers only. Identifies which airports generate the most premium/long-haul traffic. | ✅ Done |
| 3 | Slice | `slice_03_flightcount_by_airport_MU.mdx` | Flight count by departure airport, for China Eastern (MU) only. Shows one airline's own route network concentration. | ✅ Done |

More rows will be added as each operation (Dice, Drill, Rank, Top N, Moving Average, Pivot, etc.)
is completed.

## Notes

- `(null)` in a result is not an error — it correctly means no fact rows matched that specific
  combination (e.g. an airport outside the 30-airport pool used in Phase 1, or an airline with
  no flights in the filtered period/class). Distinguished from a wrong-query symptom, which
  would show `(null)` for every single row rather than a mix of real values and nulls.
- Some dimension attributes (`Year`/`Month`/`Date` under the date dimensions, `airlines`/
  `airlinesCode` under Dim Airlines) had to be manually added in the cube designer after the
  Cube Wizard's quick-create path only exposed ID columns by default — see `cube/README.md`
  for the general pattern; per-attribute fixes are noted here only if specific to a query.
- Exact dimension/attribute/measure names were confirmed via the SSMS Metadata pane before
  writing each query, rather than assumed, after an early query failed due to a naming mismatch
  (`Departure Date` originally only exposed `Date Range ID`, not `Year`/`Month`).
