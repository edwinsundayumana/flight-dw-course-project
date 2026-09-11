# MDX Queries (Phase 5 — OLAP Analysis)

21+ MDX queries demonstrating 7+ OLAP operation types (3 examples each), run against
`FlightAirticketCube` on `EDWIN\SSAS_EVAL`.

Per the assignment brief's own list — drill down, roll up, slice, dice, rank, moving avg,
top n — these are treated as **7 separate operations** (not drill down/up combined into one),
matching the "7+ operations × 3 examples = 21+" structure exactly.

## Naming convention

`<operation>_<number>_<short description>.mdx`, with a matching `<same name>_result.txt`
holding that query's exported result grid.

## Progress

| # | Operation | File | Business question | Status |
|---|---|---|---|---|
| 1 | Slice | `slice_01_price_by_airline_march2021.mdx` | Total ticket revenue by airline, for March 2021 only. Helps identify which airlines were strongest in a specific period (e.g. seasonal/holiday performance). | ✅ Done |
| 2 | Slice | `slice_02_mileage_by_airport_firstclass.mdx` | Total mileage flown by departure airport, for First Class passengers only. Identifies which airports generate the most premium/long-haul traffic. | ✅ Done |
| 3 | Slice | `slice_03_flightcount_by_airport_MU.mdx` | Flight count by departure airport, for China Eastern (MU) only. Shows one airline's own route network concentration. | ✅ Done |
| 4 | Dice | `dice_01_price_by_airline_q1_business.mdx` | Total revenue by airline, for Q1 2021 (Jan-Mar) AND Business class only. Combines a time range with a class filter simultaneously. | ✅ Done |
| 5 | Dice | `dice_02_flightcount_by_airport_age50plus_premium.mdx` | Flight count by departure airport, for passengers aged 51-90 AND flying First or Business class. Targets a specific demographic + premium segment together. | ✅ Done |
| 6 | Dice | `dice_03_avgrate_by_airline_transit_specific_airport.mdx` | Average discount rate by airline, for flights with a real transit/stopover AND departing from a specific airport (漠河机场). Uses a calculated member (average) and excludes the "no transit" placeholder member. | ✅ Done |
| 7 | Drill Down | `drilldown_01_price_by_month_2021.mdx` | Total revenue for 2021, drilled down into its individual months. Direct summary-to-detail navigation within the Calendar hierarchy. | ✅ Done |
| 8 | Drill Down | `drilldown_02_flightcount_by_day_march2021.mdx` | Flight count for March 2021, drilled down into individual days. Goes one level deeper (Month -> Date). | ✅ Done |
| 9 | Drill Down | `drilldown_03_price_by_airline_month_2021.mdx` | Revenue by airline for 2021, drilled down to each airline's monthly breakdown. Combines the Year->Month drill with a second dimension (Airline) via cross-join. | ✅ Done |

More rows will be added as each remaining operation (Roll Up, Rank, Moving Average, Top N) is
completed.

## Notes

- `(null)` in a result is not an error — it correctly means no fact rows matched that specific
  combination (e.g. an airport outside the 30-airport pool used in Phase 1, a month with no
  flights, or an airline with no flights in the filtered period/class/demographic).
  Distinguished from a wrong-query symptom, which would show `(null)` for every single row
  rather than a mix of real values and nulls.
- Several dimension attributes had to be manually added in the cube designer after the Cube
  Wizard's quick-create path only exposed ID columns by default: `Year`/`Month`/`Date` under
  the date dimensions, `airlines`/`airlinesCode` under Dim Airlines, and `PassengerAge`/
  `PassengerGender`/`PassengerWorkplace`/`FFP_TIER`/`FLIGHT_COUNT`/`PassengerName` under Dim
  Passenger. See `cube/README.md`.
- While adding the Dim Passenger attributes, cube processing failed with an "attribute key
  cannot be found" error, traced to 735 `PassengerWorkplace` values containing a Chinese
  "ideographic space" character (`NCHAR(12288)`) inconsistently. Fixed with
  `REPLACE(PassengerWorkplace, NCHAR(12288), '')` rather than `TRIM`, since the character was
  embedded mid-string, not at the edges. See `queries/12_fix_passenger_workplace_special_space.sql`.
- Exact dimension/attribute/measure names were confirmed via the SSMS Metadata pane before
  writing each query, rather than assumed, after an early query failed due to a naming mismatch
  (`Departure Date` originally only exposed `Date Range ID`, not `Year`/`Month`).
- MDX has no direct "IS NOT NULL" filter the way SQL does. To find rows with a genuine transit
  stop, we exclude the dimension's automatic `.UnknownMember` placeholder using `EXCEPT(...)`.
  Naming this exclusion as a separate `WITH SET` and referencing it in `WHERE` triggered a false
  "circular reference" error; fixed by inlining the `EXCEPT(...)` expression directly.
- Referencing the same hierarchy at two different levels in two different places in one query
  (e.g. `[Calendar].[Month]` on ROWS and separately `[Calendar].[Year]` in `WHERE`) causes a
  "hierarchy already appears in axis" error. Fixed by using `.Children` off a specific member
  instead (e.g. `[Calendar].[Year].&[2021].Children`), which expresses "drill into this member"
  in a single hierarchy reference rather than two conflicting ones.

