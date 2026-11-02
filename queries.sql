-- In this SQL file, write (and comment!) the typical SQL queries users will run on your database

-- Adding categories
INSERT INTO "categories" ("name", "description") VALUES
    ('Drinks', 'juices, water, sweet drinks'),
    ('Dairy products', 'milk, cheese, yogurts'),
    ('Baking', 'bread, cakes, baguette'),
    ('Sweets', 'candies, cookies, cupcakes');


-- Adding porducts
INSERT INTO "products" ("barcode", "name", "category_id", "price", "stock_quantity") VALUES
    ('4820000000010', 'Apple juice 1L', 1, 14.50, 70),
    ('4820000000044', 'Milk 2.5% 1L', 2, 4.25, 50),
    ('4820000000076', 'Whole-grain bread 500G', 3, 2.10, 20),
    ('4820000000080', 'Chocolate candies 100G', 4, 0.80, 80);

-- Adding customers
INSERT INTO "customers" ("full_name", "phone", "bonus_points", "created_at") VALUES
    ('John Aminson', '+123011112233', 50, datetime('2024-06-12 11:33:21')),
    ('Anna Dattery', '+123033332211', 60, datetime('2023-02-08 10:20:58'));

-- Creating orders
INSERT INTO "orders" ("customer_id", "order_date", "total_amount") VALUES
    (1, datetime('2025-08-12 15:23:46'), 33.20),
    (2, datetime('2025-08-14 12:04:01'), 10.10);

-- Adding products to receipts
INSERT INTO "order_items" ("order_id", "product_id", "quantity", "unit_price") VALUES
    (1, 1, 2, 14.50),
    (1, 3, 2, 2.10),
    (2, 4, 2, 0.80),
    (2, 2, 2, 4.25);

-- Select TOP-2 the most popular products by by number of units sales
SELECT "products"."name", SUM("order_items"."quantity") as "count_of_sales"
FROM "order_items"
INNER JOIN "products" ON "products"."id" = "order_items"."product_id"
INNER JOIN "orders" ON "orders"."id" = "order_items"."order_id"
WHERE "orders"."status" = 'completed'
GROUP BY "products"."id"
ORDER BY 2 DESC
LIMIT 2;

-- write-off of goods from a sale under order 1
UPDATE "products"
SET "stock_quantity" = "stock_quantity" - 2
WHERE "id" = 1;

-- write-off of goods from a sale under order 1
UPDATE "products"
SET "stock_quantity" = "stock_quantity" - 2
WHERE "id" = 3;

--accrual of bonuses for a purchase from order 1
UPDATE "customers"
SET "bonus_points" = "bonus_points" + (33.20 * 0.11)
WHERE "id" = 1;

-- write-off of goods from a sale under order 2
UPDATE "products"
SET "stock_quantity" = "stock_quantity" - 2
WHERE "id" = 4;

-- write-off of goods from a sale under order 2
UPDATE "products"
SET "stock_quantity" = "stock_quantity" - 2
WHERE "id" = 2;

--accrual of bonuses for a purchase from order 2
UPDATE "customers"
SET "bonus_points" = "bonus_points" + (10.10 * 0.11)
WHERE "id" = 2;

-- creating order No 3 and adding products to order by using triggers
INSERT INTO "orders" ("customer_id") VALUES (1);
INSERT INTO "order_items" ("order_id", "product_id", "quantity", "unit_price") VALUES (3, 1, 1, 14.50);

--accrual of bonuses for a purchase from order 3
-- Initially, a trigger was in place that automatically calculated the "total_amount", but bonuses for a purchase had to be credited to the customer manually.
-- After this order was placed, the trigger was updated so that, in addition to automatically calculating the total amount for the receipt, it also automatically credited bonuses to the customer.
UPDATE "customers"
SET "bonus_points" = "bonus_points" + (14.50 * 0.11)
WHERE "id" = 1;

-- creating order No 4 and adding products to order by using triggers
INSERT INTO "orders" ("customer_id") VALUES (2);
INSERT INTO "order_items" ("order_id", "product_id", "quantity", "unit_price") VALUES (4, 2, 1, (SELECT "price" FROM "products" WHERE "id" = 2));
