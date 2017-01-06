-- PO view
SELECT po.id
, po.createdDate
, s.companyname AS "Supplier Company"
, sa.townOrCity AS "Supplier Location"
, sc.GivenName || ' ' || sc.FamilyName AS "Supplier Contact"
, po.ordertotal
, os.StatusName
, po.completeddate
 FROM PurchaseOrder po
INNER JOIN Supplier s
ON po.supplierId = s.id
INNER JOIN Address sa
ON s.CompanyAddrId = sa.id
INNER JOIN Person sc
ON s.MainContactId = sc.id
INNER JOIN OrderStatus os
ON po.OrderStatusId = os.id
WHERE os.StatusName = 'Pending'

UPDATE PurchaseOrder
SET CompletedDate = NULL
WHERE OrderStatusId = (
  SELECT id FROM OrderStatus
  WHERE StatusName = 'Pending'
)

UPDATE PurchaseOrder
SET OrderTotal = (SELECT SUM(PurchasePrice)
                  FROM PurchaseOrderLine pol
                  WHERE PurchaseOrder.id = pol.PurchOrderId
                  GROUP BY PurchOrderId
                )

SELECT Title || ' ' || p.GivenName || ' ' || p.FamilyName AS "Customer Name"
, p.email AS "Customer Email"
, p.tel AS "Customer Contact Tel"
, SUM(co.OrderTotal) AS "Total Of Totals"
, MAX(co.OrderTotal) AS "Big Spender Order"
, ROUND(AVG(co.OrderTotal), 2) AS "Average Order"
FROM Person p
INNER JOIN Customer c
ON p.id = c.PersonId
INNER JOIN CustomerOrder co
ON c.id = co.CustomerId
GROUP BY p.Title
, p.GivenName
, p.FamilyName
, p.email
, p.tel
ORDER BY SUM(co.OrderTotal) DESC

SELECT to_char(p.dateOfBirth, 'DD MON') AS "Birthday"
, p.title || ' ' || p.givenName || ' ' || p.middleName || ' ' || p.FamilyName AS "Customer Name"
, a.AddressLine1
, a.AddressLine2
, a.townOrCity
, a.County
, a.Country
, a.PostCode
FROM Person p
INNER JOIN Customer c
ON p.id = c.PersonId
INNER JOIN Address a
ON c.shippingAddressId = a.id
WHERE p.dateOfBirth IS NOT NULL
AND extract(month FROM p.dateOfBirth) = 9
