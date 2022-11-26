-- Lab 3
-- mwingerd
-- Oct 18, 2022

-- USE `mwingerd`;
-- BAKERY-1
-- Using a single SQL statement, reduce the prices of Lemon Cake and Napoleon Cake by $2.
UPDATE 
    goods
SET
    Price = Price - 2
WHERE
    Flavor = 'Lemon' AND
    Food = 'Cake' OR
    Flavor = 'Napoleon' AND
    Food = 'Cake';


-- USE `mwingerd`;
-- BAKERY-2
-- Using a single SQL statement, increase by 15% the price of all Apricot or Chocolate flavored items with a current price below $5.95.
UPDATE
    goods
Set
    Price = CASE
        WHEN Price < 5.95 THEN Price + (Price * .15)
        ELSE Price
    END
WHERE
    Flavor = 'Apricot' OR
    Flavor = 'Chocolate';


--USE `mwingerd`;
-- BAKERY-3
-- Add the capability for the database to record payment information for each receipt in a new table named payments (see assignment PDF for task details)
DROP TABLE IF EXISTS payments;

CREATE TABLE payments (
    Receipt INTEGER NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    PaymentSettled DATETIME NOT NULL,
    PaymentType VARCHAR(50) NOT NULL,
    
    FOREIGN KEY (Receipt)
        REFERENCES receipts(RNumber),
    UNIQUE(Receipt, Amount, PaymentSettled, PaymentType)
);


--USE `mwingerd`;
-- BAKERY-4
-- Create a database trigger to prevent the sale of Meringues (any flavor) and all Almond-flavored items on Saturdays and Sundays.
DROP TRIGGER IF EXISTS BadSaleDate;

CREATE TRIGGER BadSaleDate BEFORE INSERT ON items
FOR EACH ROW
BEGIN
    DECLARE buyDate DATE;
    SET buyDate := (SELECT SaleDate FROM receipts WHERE NEW.Receipt = RNumber);
    IF (WEEKDAY(buyDate) = 5 OR WEEKDAY(buyDate) = 6) THEN
        IF (locate('70-M', NEW.Item) > 0 OR locate('ALM', NEW.Item) > 0 OR locate('ATW', NEW.ITem) > 0) THEN 
            SIGNAL SQLSTATE '45000';
        END IF;
    END IF;
END;


--USE `mwingerd`;
-- AIRLINES-1
-- Enforce the constraint that flights should never have the same airport as both source and destination (see assignment PDF)
DROP TRIGGER IF EXISTS flightSourceDest;

CREATE TRIGGER flightSourceDest BEFORE INSERT ON flights
    FOR EACH ROW
        BEGIN
            IF (NEW.SourceAirport = NEW.DestAirport) THEN
                SIGNAL SQLSTATE '45000';
            END IF;
        END;


--USE `mwingerd`;
-- AIRLINES-2
-- Add a "Partner" column to the airlines table to indicate optional corporate partnerships between airline companies (see assignment PDF)
ALTER TABLE airlines
ADD Partner VARCHAR(50) DEFAULT NUll AFTER Country;

ALTER TABLE airlines
ADD UNIQUE(Partner);

UPDATE
    airlines
SET
    Partner = 'JetBlue'
WHERE
    Abbreviation = 'Southwest';

UPDATE
    airlines
SET
    Partner = 'Southwest'
WHERE
    Abbreviation = 'JetBlue';


DROP TRIGGER IF EXISTS selfPartnership;
CREATE TRIGGER selfPartnership BEFORE INSERT ON airlines
    FOR EACH ROW
        BEGIN
            IF (NEW.Partner IS NOT NULL) THEN
                IF (NEW.Abbreviation = NEW.Partner) THEN
                    SIGNAL SQLSTATE '45000';
                END IF;
            END IF;
        END;

DROP TRIGGER IF EXISTS nonExistantAirlines;
CREATE TRIGGER nonExistantAirlines BEFORE INSERT ON airlines
    FOR EACH ROW
        BEGIN
            DECLARE existance VARCHAR(50);
            IF (NEW.Partner IS NOT NULL) THEN
                SET existance := (SELECT Abbreviation FROM airlines WHERE Abbreviation = NEW.Partner);
                IF (existance IS NULL) THEN
                    SIGNAL SQLSTATE '45000';
                END IF;
            END IF;
        END;


--USE `mwingerd`;
-- KATZENJAMMER-1
-- Change the name of two instruments: 'bass balalaika' should become 'awesome bass balalaika', and 'guitar' should become 'acoustic guitar'. This will require several steps. You may need to change the length of the instrument name field to avoid data truncation. Make this change using a schema modification command, rather than a full DROP/CREATE of the table.
UPDATE
    Instruments
SET
    Instrument = 'awesome bass balalaika'
WHERE
    Instrument = 'bass balalaika';
    
UPDATE
    Instruments
SET
    Instrument = 'acoustic guitar'
WHERE
    Instrument = 'guitar';


--USE `mwingerd`;
-- KATZENJAMMER-2
-- Keep in the Vocals table only those rows where Solveig (id 1 -- you may use this numeric value directly) sang, but did not sing lead.
DELETE FROM Vocals
    WHERE Bandmate != 1 OR Type = 'lead';


