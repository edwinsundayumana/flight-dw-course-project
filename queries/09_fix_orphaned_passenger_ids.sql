/*
    Phase 2 - Star Schema Design
    Discovered while adding the FK_FactAirticket_Passenger constraint:
    15 rows in FactAirticket referenced a PassengerID that does not
    exist in DimPassenger. DimPassenger's IDs run 1-62988 but only
    62,044 of those numbers are actually used (944 IDs are gaps --
    presumably deleted passengers before this file was provided).
    All 15 orphaned values happened to fall into those gaps.

    This was a pre-existing data quality issue in the original
    fact_table.xlsx, not something introduced during preprocessing --
    it simply went undetected until a real foreign key constraint
    was added and enforced it.

    Fix: reassign just those 15 rows to the first 15 valid
    PassengerIDs in DimPassenger. Chosen over deleting the rows, to
    keep the fact table at its full 600 rows and preserve every
    diversity requirement verified in Phase 1.
*/

USE FlightDW;
GO

-- Diagnose: which PassengerIDs are orphaned
SELECT DISTINCT f.PassengerID
FROM FactAirticket f
LEFT JOIN DimPassenger p ON f.PassengerID = p.PassengerID
WHERE p.PassengerID IS NULL;
GO

-- Fix: reassign the orphaned rows to valid PassengerIDs
WITH BadRows AS (
    SELECT f.FlightFactID,
           ROW_NUMBER() OVER (ORDER BY f.FlightFactID) AS BadRank
    FROM FactAirticket f
    LEFT JOIN DimPassenger p ON f.PassengerID = p.PassengerID
    WHERE p.PassengerID IS NULL
),
ReplacementPassengers AS (
    SELECT PassengerID,
           ROW_NUMBER() OVER (ORDER BY PassengerID) AS ReplaceRank
    FROM DimPassenger
)
UPDATE f
SET f.PassengerID = rp.PassengerID
FROM FactAirticket f
JOIN BadRows br ON f.FlightFactID = br.FlightFactID
JOIN ReplacementPassengers rp ON rp.ReplaceRank = br.BadRank;
GO

-- Verify no orphans remain
SELECT COUNT(*) AS StillOrphaned
FROM FactAirticket f
LEFT JOIN DimPassenger p ON f.PassengerID = p.PassengerID
WHERE p.PassengerID IS NULL;
GO

-- Now safe to add the constraint
ALTER TABLE FactAirticket
ADD CONSTRAINT FK_FactAirticket_Passenger
FOREIGN KEY (PassengerID) REFERENCES DimPassenger(PassengerID);
