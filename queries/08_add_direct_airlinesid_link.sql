/*
    Phase 2 - Star Schema Design
    Originally, "which airline" required a two-hop join
    (FactAirticket -> DimTicket -> DimAirlines). Adds a direct
    AirlinesID column to the fact table so airline is a first-class
    dimension, one join away, matching the intended schema design.
    No new data is invented -- values are looked up from the
    existing TicketID -> DimTicket -> DimAirlines chain.
*/

USE FlightDW;
GO

-- Step 1: add the column, nullable for now
ALTER TABLE FactAirticket
ADD AirlinesID INT NULL;
GO

-- Step 2: populate via the existing TicketID -> DimTicket -> DimAirlines chain
UPDATE f
SET f.AirlinesID = a.AirlinesID
FROM FactAirticket f
JOIN DimTicket t ON f.TicketID = t.TicketID
JOIN DimAirlines a ON LEFT(t.FlightNo, 2) = a.airlinesCode;
GO

-- Step 3: forbid future blanks
ALTER TABLE FactAirticket
ALTER COLUMN AirlinesID INT NOT NULL;
GO

-- Step 4: foreign key constraint
ALTER TABLE FactAirticket
ADD CONSTRAINT FK_FactAirticket_Airlines
FOREIGN KEY (AirlinesID) REFERENCES DimAirlines(AirlinesID);
GO

-- Verify
SELECT COUNT(*) AS TotalRows, COUNT(AirlinesID) AS NonBlankAirlinesID FROM FactAirticket;
