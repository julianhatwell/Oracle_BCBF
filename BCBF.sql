DROP USER Bob_Downs CASCADE;
DROP USER Vic_Murphy CASCADE;
DROP USER Laurie_Mapplethorpe CASCADE;

DROP ROLE Role_Sales_Exec;
DROP ROLE Role_Sales_Admin;
DROP ROLE Role_Production_Exec;
DROP ROLE Role_Inventory_Manager;

DROP PROFILE bcbf_default;

DROP VIEW v_InventoryOverview;
DROP VIEW v_WorksOrdersListing;
DROP VIEW v_CustomerOrderDetails;
DROP VIEW v_CustomerDetails;

DROP TABLE Payment;
DROP TABLE Receipt;
DROP TABLE CashTransaction;
DROP TABLE PurchaseOrderLine;
DROP TABLE PurchaseOrder;
DROP TABLE StockItemSupplier;
DROP TABLE Supplier;
DROP TABLE ProductStockItem;
DROP TABLE StockItem;
DROP TABLE CustomerOrderLine;
DROP TABLE Product;
DROP TABLE Invoice;
DROP TABLE WorksOrder;
DROP TABLE CustomerOrder;
DROP TABLE CustOrderAddress;
DROP TABLE OrderStatus;
DROP TABLE Employee;
DROP TABLE Customer;
DROP TABLE Address;
DROP TABLE Person;

DROP CLUSTER ClusProduct;
DROP CLUSTER ClusCashTrans;
DROP CLUSTER ClusCustOrder;
DROP CLUSTER ClusPerson;


/* all tables that "descend" from Person will be stored in a cluster
Person - Customer - Employee
because they will almost always be searched and joined together.
Index is cluster chosen. Although the data is changing very slowly, it is still changing.
If the company grew, there would be the risk of having to rebuild a hash cluster.
New customers at added at most a couple of time per day.
New employees are added at most once or twice per month. */
CREATE CLUSTER ClusPerson (clusPersonId INTEGER);
CREATE INDEX idx__clusperson ON CLUSTER ClusPerson;

/* all tables that "descend" from CustomerOrder will be stored in a cluster
CustomerOrder - WorksOrder - CustomerOrderLine
because they will almost always be searched and joined together.
Index is cluster chosen. This is the bread and butter operation of the database
and probably the fastest moving. */
CREATE CLUSTER ClusCustOrder (clusCustOrderId INTEGER);
CREATE INDEX idx__clusCustOrder ON CLUSTER ClusCustOrder;

/* all tables that "descend" from CashTransaction will be stored in a cluster
CashTransaction - Receipt - Payment
because they will almost always be searched and joined together.
Index is cluster chosen. This another fast(ish) moving set of operational data. */
CREATE CLUSTER ClusCashTrans (clusCashTransId INTEGER);
CREATE INDEX idx__clusCashTrans ON CLUSTER ClusCashTrans;

/* Product and ProductStockItem will be clustered.
They will frequently be searched together using Product.Id = ProductStockItem.ProductId
This data will change infrequently, perhaps per season or annually
And the size of the product catalogue will not grow linearly with cutomers and orders */
CREATE CLUSTER ClusProduct (ClusProductId INTEGER)
SIZE 1305
HASH IS ClusProductId HASHKEYS 200;
/* Size is (255 + 6) * 5 (integer, 2-precision number and varchar(100) + varchar(250) from Product table
plus three integers from ProductStockItem table) multiplied by average of 5 stock items per Product
Maximum 200 products at any time in the catalogue */


CREATE TABLE Person (
id INTEGER NOT NULL
, title VARCHAR(10) NULL
, givenName VARCHAR2(20) NOT NULL
, middleName VARCHAR2(20) NULL
, familyName VARCHAR2(20) NOT NULL
, dateOfBirth DATE NULL
, email VARCHAR2(50) NOT NULL
, tel VARCHAR2(20) NULL
, CONSTRAINT pk__person PRIMARY KEY (id)
, CONSTRAINT uq__pers_email UNIQUE (email)
, CONSTRAINT chk__title_value CHECK (title IN ('Mr', 'Ms', 'Mrs', 'Miss', 'Dr', 'Sir', 'Rt. Hon.', 'Lord', 'HRH'))
, CONSTRAINT chk__gname_format CHECK (REGEXP_INSTR(givenName, '[0-9!"£$€&*()_=+<>,\/]', 1, 1) = 0)
, CONSTRAINT chk__mname_format CHECK (REGEXP_INSTR(givenName, '[0-9!"£$€&*()_=+<>,\/]', 1, 1) = 0)
, CONSTRAINT chk__fname_format CHECK (REGEXP_INSTR(givenName, '[0-9!"£$€&*()_=+<>,\/]', 1, 1) = 0)
, CONSTRAINT chk__email_format CHECK (REGEXP_LIKE(email, '[a-zA-Z0-9._%-]+@[a-zA-Z0-9._%-]+\.[a-zA-Z]{2,4}'))
)
CLUSTER ClusPerson (Id);

-- Person Data
-- first row
INSERT INTO Person VALUES (1, 'Mr', 'Dermot', 'Oh' , 'Really', '5-Sep-1973', 'dermot.oh.really@mail.bcu.ac.uk', '0121012');
DECLARE max_value NUMBER := 10;
	randchr CHAR(1);
--start of script
BEGIN
--go round the loop max_value times - value supplied by the user
  FOR i IN 1..max_value LOOP
	-- create a random character
	SELECT DBMS_RANDOM.STRING('L', 1) INTO randchr FROM Dual;
	--insert the values in to the table created above
	INSERT INTO Person VALUES ((SELECT MAX(id) + 1 FROM Person)
								, 'Mr', 'Julian' || randchr, 'C' , 'Hatwell', '5-Sep-1973', 'julian' || to_char(i) || '.hatwell@mail.bcu.ac.uk', '0121012');
	INSERT INTO Person VALUES ((SELECT MAX(id) + 1 FROM Person)
								, 'Mr', 'Jeffrey' || randchr, 'J.', 'Juniper', NULL, 'jeff' || to_char(i) || '@bcu.ac.uk', '0121012');
	INSERT INTO Person VALUES ((SELECT MAX(id) + 1 FROM Person)
								, 'Mrs', 'Mary' || randchr, NULL, 'Mullett', '3-Mar-1980', 'mary' || to_char(i) || '@bcu.ac.uk', '0121012345');
	INSERT INTO Person VALUES ((SELECT MAX(id) + 1 FROM Person)
								, 'Dr', 'Peter' || randchr, NULL, 'Porridge', NULL, 'peter' || to_char(i) || '@bcu.ac.uk', '012101254');
	INSERT INTO Person VALUES ((SELECT MAX(id) + 1 FROM Person)
								, 'Ms', 'Sally' || randchr, NULL, 'Cinammon', NULL, 'Sally' || to_char(i) || '@bcu.ac.uk', '0121012243');
	INSERT INTO Person VALUES ((SELECT MAX(id) + 1 FROM Person)
								, 'Ms', 'Phenella' || randchr, NULL, 'Phennel', NULL, 'phen' || to_char(i) || '@bcu.ac.uk', '012101245');
	INSERT INTO Person VALUES ((SELECT MAX(id) + 1 FROM Person)
								, 'Ms', 'Doris' || randchr, 'Dalia', 'Dalrimple', NULL, 'doris' || to_char(i) || '@bcu.ac.uk', '0121012765');
	INSERT INTO Person VALUES ((SELECT MAX(id) + 1 FROM Person)
								, 'Sir', 'Charlie' || randchr, NULL, 'Cholmondeley', NULL, 'chaz' || to_char(i) || '@bcu.ac.uk', '01210123');
	INSERT INTO Person VALUES ((SELECT MAX(id) + 1 FROM Person)
								, 'Mr', 'Morris' || randchr, NULL, 'McWirter', NULL, 'mozza' || to_char(i) || '@bcu.ac.uk', '01210155');
	INSERT INTO Person VALUES ((SELECT MAX(id) + 1 FROM Person)
								, 'Mr', 'Olli' || randchr, 'Oscar', 'Oak', NULL, 'olli' || to_char(i) || '@bcu.ac.uk', '0121011');
	INSERT INTO Person VALUES ((SELECT MAX(id) + 1 FROM Person)
								, 'Rt. Hon.', 'Perry' || randchr, NULL, 'Purplepout', NULL, 'perry' || to_char(i) || '@bcu.ac.uk', '0121013');

--End of loop
  END LOOP;
-- end of script
END;
/
COMMIT;

CREATE TABLE Address (
id INTEGER NOT NULL
, addressLine1 VARCHAR2(50) NOT NULL
, addressLine2 VARCHAR2(50) NULL
, townOrCity VARCHAR2(20) NOT NULL
, county VARCHAR2(20) NULL
, country VARCHAR2(20) DEFAULT ('United Kingdom') NOT NULL
, postCode CHAR(10) NULL
, CONSTRAINT pk__address PRIMARY KEY (id)
);

-- Data
-- first row
INSERT INTO Address VALUES (1, '41 Park Hill', 'Moseley', 'Birmingham', NULL, 'United Kingdom', 'B13 8DR');

DECLARE max_value NUMBER := 10;
	randchr CHAR(1);
--start of script
BEGIN
--go round the loop max_value times - value supplied by the user
	FOR i IN 1..max_value LOOP

 --insert the values in to the table created above
	INSERT INTO Address VALUES ((SELECT MAX(id) + 1 FROM Address), to_char(i) || '42 Park Hill', 'Moseley', 'Birmingham', NULL, 'United Kingdom', 'B13 8DR');
	INSERT INTO Address VALUES ((SELECT MAX(id) + 1 FROM Address), to_char(i) || '43 Park Hill', 'Moseley', 'Birmingham', NULL, 'United Kingdom', 'B13 8DR');
	INSERT INTO Address VALUES ((SELECT MAX(id) + 1 FROM Address), to_char(i) || '44 Park Hill', 'Moseley', 'Birmingham', NULL, 'United Kingdom', 'B13 8DR');
	INSERT INTO Address VALUES ((SELECT MAX(id) + 1 FROM Address), to_char(i) || '60 Primrose Hill', 'Highgate', 'Birmingham', NULL, 'United Kingdom', 'B3 8DR');
	INSERT INTO Address VALUES ((SELECT MAX(id) + 1 FROM Address), to_char(i) || '61 Primrose Hill', 'Highgate', 'Birmingham', NULL, 'United Kingdom', 'B3 8DR');
	INSERT INTO Address VALUES ((SELECT MAX(id) + 1 FROM Address), to_char(i) || '62 Primrose Hill', 'Highgate', 'Birmingham', NULL, 'United Kingdom', 'B3 8DR');
	INSERT INTO Address VALUES ((SELECT MAX(id) + 1 FROM Address), to_char(i) || '63 Primrose Hill', 'Highgate', 'Birmingham', NULL, 'United Kingdom', 'B3 8DR');
	INSERT INTO Address VALUES ((SELECT MAX(id) + 1 FROM Address), to_char(i) || '64 Primrose Hill', 'Highgate', 'Birmingham', NULL, 'United Kingdom', 'B3 8DR');
	INSERT INTO Address VALUES ((SELECT MAX(id) + 1 FROM Address), to_char(i) || '65 Primrose Hill', 'Highgate', 'Birmingham', NULL, 'United Kingdom', 'B3 8DR');
	INSERT INTO Address VALUES ((SELECT MAX(id) + 1 FROM Address), 'Unit 1' || to_char(i), 'Mumford busines park', 'Coseley', NULL, 'United Kingdom', 'B88 8DR');
	INSERT INTO Address VALUES ((SELECT MAX(id) + 1 FROM Address), 'Unit 2' || to_char(i), 'Mumford busines park', 'Coseley', NULL, 'United Kingdom', 'B88 8DR');
  END LOOP;
-- end of script
END;
--need to enter a new line (ENTER) to make script run
/
COMMIT;

CREATE TABLE Customer (
id INTEGER NOT NULL
, billingAddressId INTEGER NOT NULL
, shippingAddressId INTEGER NOT NULL
, personId INTEGER NOT NULL
, CONSTRAINT pk__customer PRIMARY KEY (id)
, CONSTRAINT fk__cust_billaddr FOREIGN KEY (billingAddressId) REFERENCES Address (id)
, CONSTRAINT fk__cust_shipaddr FOREIGN KEY (shippingAddressId) REFERENCES Address (id)
, CONSTRAINT fk__cust_pers FOREIGN KEY (personId) REFERENCES Person (id)
, CONSTRAINT uq__cust_pers UNIQUE (personId)
) /* adding to ClusPerson as described above */
CLUSTER ClusPerson (personId);

/* Adding a unique index on personId enforces
the one to one relationship with person
and also speeds up queries joining the two tables
which is essential as it will happen all the time */

/* Index is desirable as this table will always be joined to person for queries
/* UQ Constraint already created an index - tested by trying to create an explicit index. */

-- Data
-- first row
INSERT INTO Customer VALUES (1, 1, 2, 1);
DECLARE max_value NUMBER := 8;
--start of script
BEGIN
--go round the loop max_value times - value supplied by the user
	FOR i IN 1..max_value LOOP

	INSERT INTO Customer VALUES ((SELECT MAX(id) + 1 FROM Customer), 3 + (i - 1), 3 + (i - 1), (SELECT MAX(personId) + 1 FROM Customer));
	INSERT INTO Customer VALUES ((SELECT MAX(id) + 1 FROM Customer), 4 + (i - 1), 4 + (i - 1), (SELECT MAX(personId) + 1 FROM Customer));
	INSERT INTO Customer VALUES ((SELECT MAX(id) + 1 FROM Customer), 5 + (i - 1), 6 + (i - 1), (SELECT MAX(personId) + 1 FROM Customer));
	INSERT INTO Customer VALUES ((SELECT MAX(id) + 1 FROM Customer), 7 + (i - 1), 7 + (i - 1), (SELECT MAX(personId) + 1 FROM Customer));
	INSERT INTO Customer VALUES ((SELECT MAX(id) + 1 FROM Customer), 1 + (i - 1), 2 + (i - 1), (SELECT MAX(personId) + 1 FROM Customer));
	INSERT INTO Customer VALUES ((SELECT MAX(id) + 1 FROM Customer), 3 + (i - 1), 3 + (i - 1), (SELECT MAX(personId) + 1 FROM Customer));
	INSERT INTO Customer VALUES ((SELECT MAX(id) + 1 FROM Customer), 8 + (i - 1), 8 + (i - 1), (SELECT MAX(personId) + 1 FROM Customer));
	INSERT INTO Customer VALUES ((SELECT MAX(id) + 1 FROM Customer), 1 + (i - 1), 4 + (i - 1), (SELECT MAX(personId) + 1 FROM Customer));
	INSERT INTO Customer VALUES ((SELECT MAX(id) + 1 FROM Customer), 8 + (i - 1), 9 + (i - 1), (SELECT MAX(personId) + 1 FROM Customer));
	END LOOP;
-- end of script
END;
--need to enter a new line (ENTER) to make script run
/
COMMIT;

CREATE TABLE Employee (
id INTEGER NOT NULL
, homeAddressId INTEGER NOT NULL
, personId INTEGER NOT NULL
, CONSTRAINT pk__employee PRIMARY KEY (id)
, CONSTRAINT fk__cust_homeaddr FOREIGN KEY (homeAddressId) REFERENCES Address (id)
, CONSTRAINT fk__emp_pers FOREIGN KEY (personId) REFERENCES Person (id)
, CONSTRAINT uq__emp_pers UNIQUE (personId)
) /* adding to ClusPerson as described above */
CLUSTER ClusPerson (personId);
/* Adding a unique index on personId enforces
the one to one relationship with person
and also speeds up queries joining the two tables
which is essential as it will happen all the time */

/* Index is desirable as this table will always be joined to person for queries
UQ Constraint already created an index - tested by trying to create an explicit index. */

-- Data
-- First Row
INSERT INTO Employee VALUES (1, (SELECT MAX(billingAddressId) + 1 FROM Customer), (SELECT MAX(personId) + 1 FROM Customer));
COMMIT;

DECLARE max_value NUMBER := 10;
--start of script
BEGIN
--go round the loop max_value times - value supplied by the user
	FOR i IN 2..max_value LOOP

	INSERT INTO Employee VALUES (i, (SELECT MAX(homeAddressId) + 1 FROM Employee), (SELECT MAX(personId) + 1 FROM Employee));

	END LOOP;
-- end of script
END;
--need to enter a new line (ENTER) to make script run
/
COMMIT;


CREATE TABLE OrderStatus (
id INTEGER NOT NULL
, statusName CHAR(10)
, CONSTRAINT pk__orderStatus PRIMARY KEY (id)
/* Mustn't have two names the same or it would get messy */
, CONSTRAINT uq__orderStatusName UNIQUE (statusName));


INSERT INTO OrderStatus VALUES (1, 'Pending');
INSERT INTO OrderStatus VALUES ((SELECT MAX(id) + 1 FROM OrderStatus), 'Complete');
COMMIT;

CREATE TABLE CustOrderAddress (
id INTEGER NOT NULL
, addressLine1 VARCHAR2(50) NOT NULL
, addressLine2 VARCHAR2(50) NULL
, townOrCity VARCHAR2(20) NOT NULL
, county VARCHAR2(20) NULL
, country VARCHAR2(20) DEFAULT ('United Kingdom') NOT NULL
, postCode CHAR(10) NULL
, CONSTRAINT pk__custordaddress PRIMARY KEY (id)
);

-- Data
-- first row
INSERT INTO CustOrderAddress VALUES (1, '41 Park Hill', 'Moseley', 'Birmingham', NULL, 'United Kingdom', 'B13 8DR');

DECLARE max_value NUMBER := 10;
	randchr CHAR(1);
--start of script
BEGIN
--go round the loop max_value times - value supplied by the user
	FOR i IN 1..max_value LOOP

 --insert the values in to the table created above
	INSERT INTO CustOrderAddress VALUES ((SELECT MAX(id) + 1 FROM CustOrderAddress), to_char(i) || '42 Park Hill', 'Moseley', 'Birmingham', NULL, 'United Kingdom', 'B13 8DR');
	INSERT INTO CustOrderAddress VALUES ((SELECT MAX(id) + 1 FROM CustOrderAddress), to_char(i) || '43 Park Hill', 'Moseley', 'Birmingham', NULL, 'United Kingdom', 'B13 8DR');
	INSERT INTO CustOrderAddress VALUES ((SELECT MAX(id) + 1 FROM CustOrderAddress), to_char(i) || '44 Park Hill', 'Moseley', 'Birmingham', NULL, 'United Kingdom', 'B13 8DR');
	INSERT INTO CustOrderAddress VALUES ((SELECT MAX(id) + 1 FROM CustOrderAddress), to_char(i) || '60 Primrose Hill', 'Highgate', 'Birmingham', NULL, 'United Kingdom', 'B3 8DR');
	INSERT INTO CustOrderAddress VALUES ((SELECT MAX(id) + 1 FROM CustOrderAddress), to_char(i) || '61 Primrose Hill', 'Highgate', 'Birmingham', NULL, 'United Kingdom', 'B3 8DR');
	INSERT INTO CustOrderAddress VALUES ((SELECT MAX(id) + 1 FROM CustOrderAddress), to_char(i) || '62 Primrose Hill', 'Highgate', 'Birmingham', NULL, 'United Kingdom', 'B3 8DR');
	INSERT INTO CustOrderAddress VALUES ((SELECT MAX(id) + 1 FROM CustOrderAddress), to_char(i) || '63 Primrose Hill', 'Highgate', 'Birmingham', NULL, 'United Kingdom', 'B3 8DR');
	INSERT INTO CustOrderAddress VALUES ((SELECT MAX(id) + 1 FROM CustOrderAddress), to_char(i) || '64 Primrose Hill', 'Highgate', 'Birmingham', NULL, 'United Kingdom', 'B3 8DR');
	INSERT INTO CustOrderAddress VALUES ((SELECT MAX(id) + 1 FROM CustOrderAddress), to_char(i) || '65 Primrose Hill', 'Highgate', 'Birmingham', NULL, 'United Kingdom', 'B3 8DR');
	INSERT INTO CustOrderAddress VALUES ((SELECT MAX(id) + 1 FROM CustOrderAddress), 'Unit 1' || to_char(i), 'Mumford busines park', 'Coseley', NULL, 'United Kingdom', 'B88 8DR');
	INSERT INTO CustOrderAddress VALUES ((SELECT MAX(id) + 1 FROM CustOrderAddress), 'Unit 2' || to_char(i), 'Mumford busines park', 'Coseley', NULL, 'United Kingdom', 'B88 8DR');
  END LOOP;
-- end of script
END;
--need to enter a new line (ENTER) to make script run
/
COMMIT;

CREATE TABLE CustomerOrder (
id INTEGER NOT NULL
, createdDate DATE DEFAULT SYSDATE NOT NULL
, shipDate DATE NULL
, orderTotal DECIMAL(8,2) NOT NULL
, orderStatusId INTEGER NOT NULL
, billingAddressId INTEGER NOT NULL
, shippingAddressId INTEGER NOT NULL
, customerId INTEGER NOT NULL
, CONSTRAINT pk__custorder PRIMARY KEY (id)
, CONSTRAINT fk__custorder_status FOREIGN KEY (orderStatusId) REFERENCES OrderStatus (id)
, CONSTRAINT fk__custorder_billaddr FOREIGN KEY (billingAddressId) REFERENCES CustOrderAddress (id)
, CONSTRAINT fk__custorder_shipaddr FOREIGN KEY (shippingAddressId) REFERENCES CustOrderAddress (id)
/* Avoid orders with zero or negative values */
, CONSTRAINT ck__custorder_total CHECK (orderTotal >= 0.0)
/* Can't ship earlier than the order was created! */
, CONSTRAINT ck__custorder_shipdate CHECK (shipDate > createdDate)
) /* added to ClusCustOrder as described above */
CLUSTER ClusCustOrder (id);
/* no index on order status because that is a tiny table of just a few category names
which is faster to search linearly */

-- Data
-- first row
INSERT INTO CustomerOrder VALUES (1, '5-Mar-2016', '20-Mar-2016', 1000.0, 2, 1, 10, 1);

DECLARE max_value NUMBER := 100;
	randval INTEGER;
	randdec DECIMAL(8,2);
	randnor NUMBER;
	randbin INTEGER;
	randbill INTEGER;
	randship INTEGER;
	randcust INTEGER;
--start of script
BEGIN
--go round the loop max_value times - value supplied by the user
	FOR i IN 1..max_value LOOP
	SELECT DBMS_RANDOM.NORMAL
	, trunc(DBMS_RANDOM.VALUE(1, (SELECT MAX(billingAddressId) FROM Customer)))
	INTO randnor, randbill FROM Dual;


	SELECT trunc(DBMS_RANDOM.VALUE(-1000, 1000))
	, round(DBMS_RANDOM.VALUE(200, 5000), 2)
	, CASE WHEN randnor > 0 THEN 2 ELSE 1 END
	, trunc(DBMS_RANDOM.VALUE(1, (SELECT MAX(id) FROM Customer)))
	-- unusual case is a different shipping id
	, CASE WHEN randnor > 1 THEN trunc(DBMS_RANDOM.VALUE(1, (SELECT MAX(billingAddressId) FROM Customer))) ELSE randbill END
	INTO randval, randdec, randbin, randcust, randship FROM Dual;
INSERT INTO CustomerOrder VALUES ((SELECT MAX(id) + 1 FROM CustomerOrder)
								, (SELECT to_date('2013-01-01', 'yyyy-mm-dd') + randval FROM Dual)
								, (SELECT to_date('2013-01-14', 'yyyy-mm-dd') + randval FROM Dual)
								, randdec, randbin, randbill, randship, randcust);

  END LOOP;
-- end of script
END;
--need to enter a new line (ENTER) to make script run
/
COMMIT;

CREATE TABLE WorksOrder (
id INTEGER NOT NULL
, createdDate DATE DEFAULT SYSDATE NOT NULL
, requiredDate DATE NOT NULL
, assignedToId INTEGER NOT NULL
, completedDate DATE NULL
, completedById INTEGER NULL
, customerOrderId INTEGER NOT NULL
, CONSTRAINT pk__workorder PRIMARY KEY (id)
, CONSTRAINT fk__workorder_assignEmp FOREIGN KEY (assignedToId) REFERENCES Employee (id)
, CONSTRAINT fk__workorder_completEmp FOREIGN KEY (completedById) REFERENCES Employee (id)
, CONSTRAINT fk__workorder_custorder FOREIGN KEY (customerOrderId) REFERENCES CustomerOrder (id)
, CONSTRAINT ck__workorder_reqdate CHECK (requiredDate > createdDate)
, CONSTRAINT ck__workorder_compdate CHECK (completedDate > createdDate)
/* Adding a unique index on custOrderId enforces
the one to one relationship with CustomerOrder
and also speeds up queries joining the two tables
which is essential as it will happen all the time */
, CONSTRAINT uq__workorder_custorder UNIQUE (customerOrderId)
) /* added to ClusCustOrder as described above */
CLUSTER ClusCustOrder (customerOrderId);
/* Index on FK to CustOrder is desirable as this table will often be joined to CO for queries */
/* UQ Constraint already created an index - tested by trying to create an explicit index. */

/* indices on FK to emp table (there are two such columns)
because it is realistic to have queries over
which employees were assigned and completed works orders */
CREATE INDEX idx__workorder_assignEmp ON WorksOrder (assignedToId);
CREATE INDEX idx__workorder_completEmp ON WorksOrder (completedById);


-- Data
-- first row
INSERT INTO WorksOrder VALUES (1, '6-Mar-2016', '25-Mar-2016', 1, '18-Mar-2016', 1, 1);

DECLARE max_value NUMBER := 80;
	randnor NUMBER;
	randemp1 INTEGER;
	randemp2 INTEGER;
--start of script
BEGIN
--go round the loop max_value times - value supplied by the user
	FOR i IN 1..max_value LOOP
	SELECT DBMS_RANDOM.NORMAL
	, trunc(DBMS_RANDOM.VALUE(1, (SELECT MAX(id) FROM Employee)))
	, trunc(DBMS_RANDOM.VALUE(1, (SELECT MAX(id) FROM Employee)))
	INTO randnor, randemp1, randemp2 FROM Dual;


	INSERT INTO WorksOrder VALUES (i + 1
								, (SELECT createdDate + 3 FROM CustomerOrder WHERE id = i + 1)
								, (SELECT shipDate + 4 FROM CustomerOrder WHERE id = i + 1)
								, randemp1
								, (SELECT shipDate - 2 FROM CustomerOrder WHERE id = i + 1)
								, CASE WHEN randnor > 1 THEN randemp2 ELSE randemp1 END
								, i + 1);

  END LOOP;
-- end of script
END;
--need to enter a new line (ENTER) to make script run
/
COMMIT;


CREATE TABLE Invoice (
id INTEGER NOT NULL
, createdDate DATE DEFAULT SYSDATE NOT NULL
, dueDate DATE DEFAULT SYSDATE + 30 NOT NULL
, worksOrderId INTEGER NOT NULL
, CONSTRAINT pk__invoice PRIMARY KEY (id)
, CONSTRAINT fk__invoice_workorder FOREIGN KEY (worksOrderId) REFERENCES WorksOrder (id)
/* Adding a unique index on worksOrderId enforces
the one to one relationship with WorksOrder
and also speeds up queries joining the two tables
which is essential as it will happen all the time */
, CONSTRAINT uq__invoice_workorder UNIQUE (worksOrderId)
) /* Archive old Invoices every 5 years because they're no longer accessed after an audit */
PARTITION BY RANGE (createdDate)
	(PARTITION Inv_Archive2010 VALUES LESS THAN ('1-Jan-2010')
	, PARTITION Inv_Archive2015 VALUES LESS THAN ('1-Jan-2015')
	, PARTITION Inv_Archive2020 VALUES LESS THAN ('1-Jan-2020'));
/* Index on FK to WorksOrder is desirable as this table will often be joined to WO for queries */
/* UQ Constraint already created an index - tested by trying to create an explicit index. */

-- Data
-- first row
INSERT INTO Invoice VALUES (1, '18-Mar-2016', '18-Apr-2016', 1);
DECLARE max_value NUMBER := 80;
--start of script
BEGIN
--go round the loop max_value times - value supplied by the user
	FOR i IN 1..max_value LOOP
	INSERT INTO Invoice VALUES (i + 1
								, (SELECT createdDate + 15 FROM WorksOrder WHERE id = i + 1)
								, (SELECT createdDate + 45 FROM WorksOrder WHERE id = i + 1)
								, i + 1);

  END LOOP;
-- end of script
END;
--need to enter a new line (ENTER) to make script run
/
COMMIT;

CREATE TABLE Product (
id INTEGER NOT NULL
, name VARCHAR2(100) NOT NULL
, price DECIMAL(8,2) NOT NULL
, instructions VARCHAR2(250)
, CONSTRAINT pk__product PRIMARY KEY (id)
/* Mustn't have two names the same or it would get messy */
, CONSTRAINT uq__product_name UNIQUE (name)
, CONSTRAINT ck__product_price CHECK (price >= 0.0)
) /* added to ClusProduct as described above */
CLUSTER ClusProduct (Id);

INSERT INTO Product VALUES (1, 'Oxford Armchair (Green Velvet)', 850.00, 'Take the Oxford frame, 5 foam padding packs and the green velvet upholstery and join it all together with one can of wood glue');
INSERT INTO Product VALUES ((SELECT MAX(id) + 1 FROM Product), 'Knots Landing 3 Piece Suite (Fuchsia Leather)', 1850.00, 'Take the Knots Landing frame pieces (all three of them), the 12 foam padding packs and the fuchsia leather upholstery and join it all together with 3 cans of wood glue');
COMMIT;

CREATE TABLE CustomerOrderLine (
customerOrderId INTEGER NOT NULL
, productId INTEGER NOT NULL
, quantity INTEGER NOT NULL
/* Composite Key as this is an n-to-m relationship table */
, CONSTRAINT pk__custorderline PRIMARY KEY (customerOrderId, productId)
, CONSTRAINT fk__custorderline_custorder FOREIGN KEY (customerOrderId) REFERENCES CustomerOrder (id)
, CONSTRAINT fk__custorderline_prod FOREIGN KEY (productId) REFERENCES Product (id)
) /* added to ClusCustOrder as described above */
CLUSTER ClusCustOrder (customerOrderId);
/* The two columns used in most searches are already part of the composite key
Won't add any index*/


INSERT INTO CustomerOrderLine VALUES (1, 1, 2);
INSERT INTO CustomerOrderLine VALUES (1, 2, 1);
INSERT INTO CustomerOrderLine VALUES (2, 1, 1);
INSERT INTO CustomerOrderLine VALUES (3, 1, 1);
INSERT INTO CustomerOrderLine VALUES (4, 2, 2);
COMMIT;

CREATE TABLE StockItem (
id INTEGER NOT NULL
, name VARCHAR2(100) NOT NULL
, goodsInQty INTEGER DEFAULT (0) NOT NULL
, warehouseQty INTEGER DEFAULT (0) NOT NULL
, workshopQty INTEGER DEFAULT (0) NOT NULL
, CONSTRAINT pk__stktem PRIMARY KEY (id)
/* Mustn't have two names the same or it would get messy */
, CONSTRAINT uq__stktem_name UNIQUE (name)
/* can never be fewer than zero */
, CONSTRAINT ck__stktem_ginqty CHECK (goodsInQty >= 0)
, CONSTRAINT ck__stktem_whsqty CHECK (warehouseQty >= 0)
, CONSTRAINT ck__stktem_wksqty CHECK (workshopQty >= 0)
);

INSERT INTO StockItem VALUES (1, 'Wood Glue', 0, 2, 1);
INSERT INTO StockItem VALUES ((SELECT MAX(id) + 1 FROM StockItem), 'Foam Padding Pack', 0, 20, 10);
INSERT INTO StockItem VALUES ((SELECT MAX(id) + 1 FROM StockItem), 'Oxford Chair Frame', 0, 0, 1);
INSERT INTO StockItem VALUES ((SELECT MAX(id) + 1 FROM StockItem), 'Oxford Chair Green Velvet Upholstery', 0, 2, 1);
INSERT INTO StockItem VALUES ((SELECT MAX(id) + 1 FROM StockItem), 'Knots Landing 3 Piece Suite Frame', 0, 1, 1);
INSERT INTO StockItem VALUES ((SELECT MAX(id) + 1 FROM StockItem), 'Knots Landing 3 Piece Suite Fuchsia Leather Upholstery', 0, 1, 1);
COMMIT;

CREATE TABLE ProductStockItem (
productId INTEGER NOT NULL
, stockItemId INTEGER NOT NULL
, quantity INTEGER NOT NULL
/* Composite Key as this is an n-to-m relationship table */
, CONSTRAINT pk__prodstktem PRIMARY KEY (productId, stockItemId)
, CONSTRAINT fk__prodstktem_prod FOREIGN KEY (productId) REFERENCES Product (id)
, CONSTRAINT fk__prodstktem_stktem FOREIGN KEY (stockItemId) REFERENCES StockItem (id)
, CONSTRAINT ck__prodstktem_qty CHECK (quantity >= 0)
) /* added to ClusProduct as described above */
CLUSTER ClusProduct (ProductId);
/* The two columns used in most searches are already part of the composite key
Won't add any index*/


INSERT INTO ProductStockItem VALUES (1, 1, 1);
INSERT INTO ProductStockItem VALUES (1, 2, 5);
INSERT INTO ProductStockItem VALUES (1, 3, 1);
INSERT INTO ProductStockItem VALUES (1, 4, 1);
INSERT INTO ProductStockItem VALUES (2, 1, 3);
INSERT INTO ProductStockItem VALUES (2, 2, 12);
INSERT INTO ProductStockItem VALUES (2, 5, 1);
INSERT INTO ProductStockItem VALUES (2, 6, 1);
COMMIT;

CREATE TABLE Supplier (
id INTEGER NOT NULL
, companyName VARCHAR2(50)
, companyAddrId INTEGER NOT NULL
, mainContactId INTEGER NOT NULL
, CONSTRAINT pk__supplier PRIMARY KEY (id)
/* Mustn't have two names the same or it would get messy */
, CONSTRAINT uq__supplier_name UNIQUE (companyName)
, CONSTRAINT fk__supplier_address FOREIGN KEY (companyAddrId) REFERENCES Address (id)
, CONSTRAINT fk__supplier_contact FOREIGN KEY (mainContactId) REFERENCES Person (id)
/* No unique on supplier main contact. It's feasible that the same person runs more than one company in the same industry */
);
/* index on FK to Person table because looking up the contact details will be a common query */
CREATE INDEX idx__supplier_contact ON Supplier (mainContactId);


INSERT INTO Supplier VALUES (1, 'Oak and Fold Partners', 11, 10);
INSERT INTO Supplier VALUES ((SELECT MAX(id) + 1 FROM Supplier), 'Wooken Legs Ltd', 12, 11);

CREATE TABLE StockItemSupplier (
stockItemId INTEGER NOT NULL
, supplierId INTEGER NOT NULL
, agreedPrice DECIMAL(8,2) NOT NULL
/* Composite Key as this is an n-to-m relationship table */
, CONSTRAINT pk__stktemsupp PRIMARY KEY (stockItemId, supplierId)
, CONSTRAINT fk__stktemsupp_stktem FOREIGN KEY (stockItemId) REFERENCES StockItem (id)
, CONSTRAINT fk__stktemsupp_supp FOREIGN KEY (supplierId) REFERENCES Supplier (id)
, CONSTRAINT ck__stktemsupp_agprice CHECK (agreedPrice >= 0.0)
);
/* The two columns used in most searches are already part of the composite key
Won't add any index*/


INSERT INTO StockItemSupplier VALUES (1, 1, 20.00);
INSERT INTO StockItemSupplier VALUES (1, 2, 25.00);
INSERT INTO StockItemSupplier VALUES (2, 1, 300.00);
INSERT INTO StockItemSupplier VALUES (2, 2, 305.00);
COMMIT;

CREATE TABLE PurchaseOrder (
id INTEGER NOT NULL
, createdDate DATE DEFAULT SYSDATE NOT NULL
, supplierId INTEGER NOT NULL
, orderTotal NUMBER(5) NOT NULL
, orderStatusId INTEGER NOT NULL
, completedDate DATE DEFAULT SYSDATE NULL
, CONSTRAINT pk__purchorder PRIMARY KEY (id)
, CONSTRAINT fk__purchord_supp FOREIGN KEY (supplierId) REFERENCES Supplier (id)
, CONSTRAINT fk__purchorder_status FOREIGN KEY (orderStatusId) REFERENCES OrderStatus (id)
/* Avoid orders with zero or negative values */
, CONSTRAINT ck__purchorder_total CHECK (orderTotal >= 0.0)
/* Can't complete earlier than the order was created! */
, CONSTRAINT ck__purchorder_completdate CHECK (completedDate > createdDate)
) /* Archive old POs every 5 years because they're no longer accessed after an audit */
PARTITION BY RANGE (createdDate)
	(PARTITION PO_Archive2010 VALUES LESS THAN ('1-Jan-2010')
	, PARTITION PO_Archive2015 VALUES LESS THAN ('1-Jan-2015')
	, PARTITION PO_Archive2020 VALUES LESS THAN ('1-Jan-2020'));
/* no index on order status because that is a tiny table of just a few category names
which is faster to search linearly */

/* index on FK to Supplier table because join to supplier table will be very common */
CREATE INDEX idx__purchord_supp ON PurchaseOrder (supplierId);


INSERT INTO PurchaseOrder VALUES (1, '1-May-2016', 1, 300.00, 2, '20-May-2016');
INSERT INTO PurchaseOrder VALUES ((SELECT MAX(id) + 1 FROM PurchaseOrder), '2-May-2016', 1, 300.00, 2, '22-May-2016');
INSERT INTO PurchaseOrder VALUES ((SELECT MAX(id) + 1 FROM PurchaseOrder), '4-May-2016', 2, 300.00, 1, NULL);
COMMIT;

CREATE TABLE PurchaseOrderLine (
purchOrderId INTEGER NOT NULL
, stockItemId INTEGER NOT NULL
, quantity INTEGER NOT NULL
, purchasePrice DECIMAL(8,2) NOT NULL
/* Composite Key as this is an n-to-m relationship table */
, CONSTRAINT pk__purchordline PRIMARY KEY (purchOrderId, stockItemId)
, CONSTRAINT fk__purchordline_purchord FOREIGN KEY (purchOrderId) REFERENCES PurchaseOrder (id)
, CONSTRAINT fk__purchordline_stktem FOREIGN KEY (stockItemId) REFERENCES StockItem (id)
, CONSTRAINT ck__purchordline_qty CHECK (quantity >= 0)
, CONSTRAINT ck__purchordline_purchprice CHECK (purchasePrice >= 0.0)
);
/* The two columns used in most searches are already part of the composite key
Won't add any index*/

INSERT INTO PurchaseOrderLine VALUES (1, 1, 2, 20.00);
INSERT INTO PurchaseOrderLine VALUES (1, 2, 2, 300.00);
INSERT INTO PurchaseOrderLine VALUES (2, 1, 4, 25.00);
INSERT INTO PurchaseOrderLine VALUES (2, 2, 4, 305.00);
COMMIT;

CREATE TABLE CashTransaction (
id INTEGER NOT NULL
, amount DECIMAL(8,2) NOT NULL
, createDate DATE DEFAULT SYSDATE NOT NULL
, processedDate DATE NULL
, bankDate DATE NULL
, CONSTRAINT pk__cashtrans PRIMARY KEY (id)
) /* added to ClusCashTrans as described above */
CLUSTER ClusCashTrans (Id);


INSERT INTO CashTransaction VALUES (1, 600.00, '30-May-2016', '31-May-2016', '4-Jun-2016');
INSERT INTO CashTransaction VALUES ((SELECT MAX(id) + 1 FROM CashTransaction), 610.00, '29-May-2016', '30-May-2016', '4-Jun-2016');
INSERT INTO CashTransaction VALUES ((SELECT MAX(id) + 1 FROM CashTransaction), 610.00, '18-Apr-2016', '20-Apr-2016', '25-Apr-2016');
COMMIT;

CREATE TABLE Receipt (
cashTransId INTEGER NOT NULL
, invoiceId INTEGER NOT NULL
, CONSTRAINT pk__receipt PRIMARY KEY (cashTransId, invoiceId)
/* Adding a unique index on cashTransId enforces
the one to one relationship with CashTransaction
and also speeds up queries joining the two tables
which is essential as it will happen all the time */
, CONSTRAINT uq__receipt_cashtrans UNIQUE (cashTransId)
, CONSTRAINT fk__receipt_cashtrans FOREIGN KEY (cashTransId) REFERENCES CashTransaction (id)
, CONSTRAINT fk__receipt_inv FOREIGN KEY (invoiceId) REFERENCES Invoice (id)
) /* added to ClusCashTrans as described above */
CLUSTER ClusCashTrans (cashTransId);
/* Index on FK to CashTrans is desirable as this table will often be joined to CT for queries */
/* UQ Constraint already created an index - tested by trying to create an explicit index. */

/* indices on FK to invoice because it is realistic to have queries
which look up specific invoices from cash receipts */
CREATE INDEX idx__receipt_inv ON Receipt (invoiceId);


INSERT INTO Receipt VALUES (1, 1);
INSERT INTO Receipt VALUES (2, 1);
COMMIT;

CREATE TABLE Payment (
cashTransId INTEGER NOT NULL
, purchOrderId INTEGER NOT NULL
, CONSTRAINT pk__payment PRIMARY KEY (cashTransId, purchOrderId)
/* Adding a unique index on cashTransId enforces
the one to one relationship with CashTransaction
and also speeds up queries joining the two tables
which is essential as it will happen all the time */
, CONSTRAINT uq__payment_cashtrans UNIQUE (cashTransId)
, CONSTRAINT fk__payment_cashtrans FOREIGN KEY (cashTransId) REFERENCES CashTransaction (id)
, CONSTRAINT fk__payment_purchord FOREIGN KEY (purchOrderId) REFERENCES PurchaseOrder (id)
) /* added to ClusCashTrans as described above */
CLUSTER ClusCashTrans (cashTransId);
/* Index on FK to CashTrans is desirable as this table will often be joined to CT for queries */
/* UQ Constraint already created an index - tested by trying to create an explicit index. */

/* indices on FK to invoice because it is realistic to have queries
which look up specific purchase orders from payments */
CREATE INDEX idx__payment_purch ON Payment (purchOrderId);

/* Users, Roles, Views and Security */
CREATE VIEW v_CustomerDetails AS
SELECT c.id AS "Customer No."
, p.givenName AS "Given Name"
, p.familyName AS "Family Name"
, p.dateOfBirth AS "Date of Birth"
, p.email AS "Email Address"
FROM Person p
INNER JOIN Customer c
	ON p.id = c.personId;

CREATE VIEW v_CustomerOrderDetails AS
SELECT c.id AS "Customer No."
, p.givenName AS "Given Name"
, p.familyName AS "Family Name"
, p.email AS "Email Address"
, co.createdDate AS "Order Date"
, co.shipDate AS "Ship Date"
, co.orderTotal AS "Order Total"
, os.statusName AS "Order Status"
FROM Person p
INNER JOIN Customer c
	ON p.id = c.personId
INNER JOIN CustomerOrder co
	ON c.id = co.customerId
INNER JOIN OrderStatus os
	ON co.orderStatusId = os.id;

CREATE VIEW v_WorksOrdersListing AS
SELECT wo.id AS "Works Order No."
, co.id AS "Customer Order No."
, co.customerId AS "Customer No."
, wo.createdDate AS "Order Date"
, wo.requiredDate AS "Required Date"
, p.givenName || ' ' || p.familyName AS "Assigned To"
, wo.completedDate AS "Completed Date"
, p2.givenName || ' ' || p2.familyName AS "Completed By"
FROM WorksOrder wo
INNER JOIN CustomerOrder co
	ON wo.customerOrderId = co.id
INNER JOIN Employee e
	ON wo.assignedToId = e.id
INNER JOIN Person p
	ON e.personId = p.id
LEFT OUTER JOIN Employee e2
	ON wo.completedById = e2.id
LEFT OUTER JOIN Person p2
	ON e2.personId = p2.id;

CREATE VIEW v_InventoryOverview AS
SELECT si.id AS "SKU No."
, si.name "Item Description"
, SUM(si.goodsInQty + si.warehouseQty + si.workshopQty) AS "Inventory Quantity"
, nvl(foq.ForwardOrdersQuantity, 0) AS "Forward Orders"
FROM StockItem si
LEFT OUTER JOIN (
	SELECT psi.stockItemId
	, col.quantity * psi.quantity AS ForwardOrdersQuantity
	FROM ProductStockItem psi
	INNER JOIN Product p
		ON psi.productId = p.id
	INNER JOIN CustomerOrderLine col
		ON p.id = col.productId
	INNER JOIN CustomerOrder co
		ON col.customerOrderId = co.id
	INNER JOIN OrderStatus os
		ON co.orderStatusId = os.id
	WHERE os.statusName = 'Pending'
	) foq
	ON si.id = foq.stockItemId
GROUP BY si.id
, si.name
, si.goodsInQty
, si.warehouseQty
, si.workshopQty
, foq.ForwardOrdersQuantity;

CREATE PROFILE bcbf_default LIMIT
FAILED_LOGIN_ATTEMPTS 5
PASSWORD_LIFE_TIME 60
PASSWORD_REUSE_TIME 60
PASSWORD_REUSE_MAX 5
PASSWORD_LOCK_TIME 1/24
PASSWORD_GRACE_TIME 10;

CREATE ROLE Role_Sales_Exec IDENTIFIED EXTERNALLY;
GRANT SELECT ON v_CustomerDetails TO Role_Sales_Exec;
GRANT SELECT ON v_CustomerOrderDetails TO Role_Sales_Exec;

CREATE ROLE Role_Sales_Admin IDENTIFIED EXTERNALLY;
GRANT ALTER ON Person TO Role_Sales_Admin;

CREATE ROLE Role_Production_Exec IDENTIFIED EXTERNALLY;
GRANT SELECT ON v_WorksOrdersListing TO Role_Sales_Exec;

CREATE ROLE Role_Inventory_Manager IDENTIFIED EXTERNALLY;
GRANT SELECT ON v_InventoryOverview TO Role_Sales_Exec;

CREATE USER Bob_Downs
IDENTIFIED BY AZ7BC2
PROFILE bcbf_default;
GRANT CREATE SESSION, Role_Sales_Exec, Role_Sales_Admin TO Bob_Downs;

CREATE USER Vic_Murphy
IDENTIFIED BY TigerLilly
PROFILE bcbf_default;
GRANT CREATE SESSION, Role_Production_Exec TO Vic_Murphy;

CREATE USER Laurie_Mapplethorpe
IDENTIFIED BY theShznzz
PROFILE bcbf_default;
GRANT CREATE SESSION, Role_Inventory_Manager TO Laurie_Mapplethorpe;
