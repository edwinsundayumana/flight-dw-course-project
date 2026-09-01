# Cube (Phase 4 — OLAP / SSAS)

Visual Studio 2026 Analysis Services Multidimensional project. Contains the Data Source, Data
Source View, Cube, and Dimension definitions that build `FlightAirticketCube` from the `FlightDW`
relational database.

## Environment

- Visual Studio 2026 Community
- Extension: **Microsoft Analysis Services Projects** (installed via `.vsix`, since the
  Marketplace in-app install did not complete automatically — had to be run manually)
- Project type: **Analysis Services Multidimensional Project** (not Tabular — required, since
  the assignment specifies MDX queries, which only Multidimensional cubes support)
- SSAS server instance: `EDWIN\SSAS_EVAL` (named instance, Evaluation edition — see below for why)

## Structure

- **Data Source** (`FlightDW.ds`) — connection to the `FlightDW` SQL Server database.
  Provider: Microsoft OLE DB Driver 19 for SQL Server (the older `SQLNCLI11` provider assumed
  by older tutorials is deprecated and not installed by default on modern Windows/VS).
  Impersonation mode: **"Use the service account"** (see problems/solutions below for why).
- **Data Source View** (`FlightDW.dsv`) — all 9 dimension tables + `FactAirticket`. Relationships
  were auto-detected from the 11 foreign key constraints declared in Phase 2 — no manual
  relationship drawing was needed.
- **Cube** (`FlightAirticketCube.cube`) — measure group built from `FactAirticket`. Measures:
  `Mileage`, `Price`, `Rate`, `Fact Airticket Count`. (`ian` deliberately excluded — see below.)
- **Dimensions** — 11 total (9 tables, with `DimAirport` split into 3 role-playing dimensions —
  Departure/Transit/Landing — and `DimDateRange` split into 2 — Departure Date/Arrival Date —
  matching the Phase 2 foreign key structure exactly).

## Design decisions

- **Excluded `ian` as a measure.** It's an arbitrary row-numbering column inherited from the
  original messy source file (pre-dating the proper `FlightFactID` primary key added in Phase 2).
  Summing/averaging it would produce numbers with no real meaning.
- **Some auto-created dimensions initially exposed only their ID column** (e.g. `Dim Airlines`
  only showed `AirlinesID`, not the readable `airlines` name). Fixed by manually dragging the
  missing descriptive columns (`airlines`, `airlinesCode`) from the Data Source View onto the
  dimension's Attributes list, then redeploying. Worth checking every dimension for this after
  using the Cube Wizard's quick-create path.

## Problems encountered and solutions (for report writeup)

1. **Extension install didn't auto-complete.** The Marketplace "Download" button for Microsoft
   Analysis Services Projects downloaded a `.vsix` file but did not launch it automatically.
   Fixed by closing Visual Studio fully and double-clicking the `.vsix` file directly from the
   Downloads folder to run the installer manually.

2. **`SQLNCLI11` provider not registered.** The Connection Manager's default OLE DB provider
   (SQL Server Native Client 11.0) is deprecated and not present on modern Windows. Fixed by
   switching to **Microsoft OLE DB Driver 19 for SQL Server** instead.

3. **SSL/certificate trust error on connection.** The new OLE DB driver requires an encrypted
   connection by default and does not trust SQL Server's self-signed certificate (normal on a
   personal machine with no CA-issued certificate). Fixed by setting
   **`TrustServerCertificate = True`** in the connection's advanced ("All") properties.

4. **SSAS edition bug: `'StandardDeveloper64' ... is not supported by the client`.** A confirmed
   Microsoft bug affecting the "Standard Developer" edition of SQL Server 2025/2026 Analysis
   Services — the client tooling rejects this specific edition regardless of client library
   version. Updating client libraries alone did not fix it. Resolved by installing a **second,
   separate Analysis Services instance** (named `SSAS_EVAL`) using the free **Evaluation
   edition** instead, in **Multidimensional and Data Mining Mode**, leaving the original
   Database Engine instance (hosting `FlightDW`) completely untouched.

5. **Deployment failed with an impersonation error.** `"The datasource ... contains an
   ImpersonationMode that is not supported for processing operations."` The Data Source's
   impersonation mode ("Use the credentials of the current user") only works for interactive
   browsing, not background cube processing. Fixed by switching impersonation to **"Use the
   service account"**, then granting that Windows service account explicit read access to
   `FlightDW` — see `queries/11_grant_ssas_service_account_access.sql`.

## Verification

Cube deployed and processed successfully with 0 errors. Verified working via the cube Browser:
dragging the `Price` measure and the `airlines` attribute onto the pivot grid correctly returns
one row per airline (12 rows) with summed `Price` per airline, confirming the cube, its
measures, and its dimension relationships are all functioning correctly end to end.
