/*
    Phase 1 - Preprocessing
    Requirement: PlaneID cannot be blank, and cannot all be the same.
    Problem found: 529 of 600 rows had a blank PlaneID; only 4 of the
    18 available planes were ever used.

    Fix: assign PlaneID to every row using a balanced round-robin
    across all 18 planes in DimPlane, so the distribution is even
    (each plane gets 33-34 flights) rather than a random/patchwork fix.
*/

USE FlightDW;
GO

DECLARE @PlaneCount INT = (SELECT COUNT(*) FROM DimPlane);

;WITH FactNumbered AS (
    SELECT ian, ROW_NUMBER() OVER (ORDER BY ian) AS RowNum
    FROM FactAirticket
),
PlaneNumbered AS (
    SELECT PlaneID, ROW_NUMBER() OVER (ORDER BY PlaneID) AS PlaneRank
    FROM DimPlane
)
UPDATE f
SET f.PlaneID = p.PlaneID
FROM FactAirticket f
JOIN FactNumbered fn ON f.ian = fn.ian
JOIN PlaneNumbered p ON p.PlaneRank = ((fn.RowNum - 1) % @PlaneCount) + 1;
GO

-- Verify
SELECT PlaneID, COUNT(*) AS FlightsAssigned
FROM FactAirticket
GROUP BY PlaneID
ORDER BY PlaneID;

SELECT COUNT(*) AS StillBlank FROM FactAirticket WHERE PlaneID IS NULL;
