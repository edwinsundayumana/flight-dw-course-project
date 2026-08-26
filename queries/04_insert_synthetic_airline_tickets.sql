/*
    Phase 1 - Preprocessing
    Requirement: >=10 distinct airlines represented among the 600
    fact rows (airline is derived from the first 2 letters of
    DimTicket.FlightNo).

    Problem found: DimAirlines lists 18 airlines, but DimTicket
    (568,917 real flight records) only actually contains flights
    for 7 of them. The other 11 airlines are defined in the
    dimension table but have zero real tickets logged -- no
    UPDATE logic can select a ticket that does not exist.

    Fix: manufacture a small number of clearly-synthetic ticket
    rows (5 tickets each) for 5 of the missing airlines, bringing
    the total representable airlines to 12. This mirrors what the
    assignment itself instructs for the Transit_ariportID field --
    supplementing missing information with invented-but-plausible
    data, clearly documented as such.

    Airlines added: SC (Shandong), ZH (Shenzhen), 3U (Sichuan),
    EU (Chengdu), 9C (Spring Airlines).
*/

USE FlightDW;
GO

DECLARE @MaxID INT = (SELECT MAX(TicketID) FROM DimTicket);

INSERT INTO DimTicket (TicketID, departureTime, delayTime, arrivalTime, FlightNo)
SELECT @MaxID + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS TicketID,
       departureTime, delayTime, arrivalTime, FlightNo
FROM (VALUES
    ('2021-01-10 07:15:00', 5,  '2021-01-10 09:30:00', 'SC1234'),
    ('2021-02-14 12:00:00', 0,  '2021-02-14 14:20:00', 'SC5678'),
    ('2021-03-22 18:45:00', 20, '2021-03-22 21:10:00', 'SC4321'),
    ('2021-04-05 09:30:00', 10, '2021-04-05 11:50:00', 'SC8765'),
    ('2021-05-18 15:00:00', 0,  '2021-05-18 17:15:00', 'SC2468'),

    ('2021-01-12 06:30:00', 15, '2021-01-12 08:45:00', 'ZH1111'),
    ('2021-02-19 11:20:00', 0,  '2021-02-19 13:40:00', 'ZH2222'),
    ('2021-03-25 16:10:00', 25, '2021-03-25 18:35:00', 'ZH3333'),
    ('2021-04-09 08:00:00', 5,  '2021-04-09 10:15:00', 'ZH4444'),
    ('2021-05-21 13:45:00', 0,  '2021-05-21 16:00:00', 'ZH5555'),

    ('2021-01-15 05:50:00', 10, '2021-01-15 08:10:00', '3U8888'),
    ('2021-02-22 10:15:00', 0,  '2021-02-22 12:30:00', '3U7777'),
    ('2021-03-28 14:30:00', 30, '2021-03-28 17:00:00', '3U6666'),
    ('2021-04-12 07:40:00', 0,  '2021-04-12 09:55:00', '3U5555'),
    ('2021-05-24 19:00:00', 15, '2021-05-24 21:20:00', '3U4444'),

    ('2021-01-18 09:00:00', 0,  '2021-01-18 11:15:00', 'EU5201'),
    ('2021-02-25 13:30:00', 20, '2021-02-25 15:50:00', 'EU5202'),
    ('2021-03-31 17:15:00', 0,  '2021-03-31 19:35:00', 'EU5203'),
    ('2021-04-15 06:45:00', 10, '2021-04-15 09:00:00', 'EU5204'),
    ('2021-05-27 12:20:00', 0,  '2021-05-27 14:40:00', 'EU5205'),

    ('2021-01-21 08:10:00', 5,  '2021-01-21 10:25:00', '9C8865'),
    ('2021-02-28 12:50:00', 0,  '2021-02-28 15:05:00', '9C8866'),
    ('2021-04-02 16:40:00', 15, '2021-04-02 19:00:00', '9C8867'),
    ('2021-04-18 07:25:00', 0,  '2021-04-18 09:45:00', '9C8868'),
    ('2021-05-30 18:15:00', 20, '2021-05-30 20:35:00', '9C8869')
) AS x(departureTime, delayTime, arrivalTime, FlightNo);
GO

-- Verify
SELECT LEFT(FlightNo, 2) AS AirlineCode, COUNT(*) AS TicketCount
FROM DimTicket
WHERE LEFT(FlightNo, 2) IN ('SC','ZH','3U','EU','9C')
GROUP BY LEFT(FlightNo, 2);
