-- In this SQL file, write (and comment!) the schema of your database, including the CREATE TABLE, CREATE INDEX, CREATE VIEW, etc. statements that compose it

-- creating table "categories"
CREATE TABLE "categories" (
    "id" INTEGER,
    "name" TEXT NOT NULL UNIQUE,
    "description" TEXT,
    PRIMARY KEY("id")
);

-- creating table "products"
CREATE TABLE "products" (
    "id" INTEGER,
    "barcode" TEXT UNIQUE NOT NULL,
    "name" TEXT NOT NULL,
    "category_id" INTEGER,
    "price" NUMERIC NOT NULL CHECK ("price" >= 0),
    "stock_quantity" INTEGER NOT NULL DEFAULT 0 CHECK ("stock_quantity" >= 0),
    PRIMARY KEY("id"),
    FOREIGN KEY ("category_id") REFERENCES "categories"("id") ON DELETE SET NULL -- deleting the primary key ("categories"("id")) will result in the foreign key ("category_id") being set to NULL.
);

-- creating table "customers"
CREATE TABLE "customers" (
    "id" INTEGER,
    "full_name" TEXT NOT NULL,
    "phone" TEXT UNIQUE NOT NULL,
    "bonus_points" INTEGER NOT NULL DEFAULT 0 CHECK ("bonus_points" >= 0),
    "created_at" NUMERIC DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("id")
);

-- creating table "orders"
CREATE TABLE "orders" (
    "id" INTEGER,
    "customer_id" INTEGER,
    "order_date" NUMERIC DEFAULT CURRENT_TIMESTAMP,
    "total_amount" NUMERIC NOT NULL DEFAULT 0 CHECK ("total_amount" >= 0),
    "status" TEXT NOT NULL CHECK ("status" IN ('completed', 'declined')) DEFAULT 'completed',
    PRIMARY KEY ("id"),
    FOREIGN KEY ("customer_id") REFERENCES "customers"("id") ON DELETE SET NULL -- deleting the primary key "customers"("id") will result in the foreign key ("customer_id") being set to NULL.
);

-- creating table "orders"
CREATE TABLE "order_items" (
    "id" INTEGER,
    "order_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL CHECK ("quantity" >= 0),
    "unit_price" NUMERIC NOT NULL CHECK ("unit_price" >= 0),
    PRIMARY KEY ("id"),
    FOREIGN KEY ("order_id") REFERENCES "orders"("id") ON DELETE CASCADE, -- deleting the primary key "orders"("id") will result in the deletion of the foreign key ("order_id").
    FOREIGN KEY ("product_id") REFERENCES "products"("id") ON DELETE RESTRICT -- prevents the deletion of a primary key "products"("id") if it has a foreign key ("product_id").
);

-- quick search by product name
CREATE INDEX indx_customer ON "orders"("customer_id");
-- quick search by order date
CREATE INDEX indx_order_date ON "orders"("date");
-- quick search by product name
CREATE INDEX indx_products_name ON "products"("name");
-- quick search by product barcode
CREATE INDEX indx_product_barcode ON "products"("barcode");

-- creating a view for tracking items with low stock
CREATE VIEW "view_of_low_quantity_in_stock" AS
    SELECT "products"."id", "products"."barcode", "products"."name" as "product_name", "categories"."name", "products"."stock_quantity"
    FROM "products"
    LEFT JOIN "categories" ON "categories"."id" = "products"."category_id"
    WHERE "products"."stock_quantity" < 11;

-- creating a view for tracking pivot table of products by the categories
CREATE VIEW "view_pivot_table_of_products_by_the_categories" AS
    SELECT "categories"."name", "categories"."description", COUNT("products"."id") AS "count_of_products", ROUND(AVG("products"."price"),2) AS "avg_price", MIN("products"."price") AS "min_price", MAX("products"."price") AS "max_price"
    FROM "products"
    INNER JOIN "categories" ON "products"."category_id" = "categories"."id"
    GROUP BY "categories"."name";

-- creating trigger "checking_subtraction_stock_quantity_products"
CREATE TRIGGER "checking_subtraction_stock_quantity_products"
AFTER INSERT ON "order_items"
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'Insufficient stock in the warehouse')
    WHERE (SELECT "stock_quantity" FROM "products" WHERE "id" = NEW."product_id") < NEW."quantity";

    UPDATE "products"
    SET "stock_quantity" = "stock_quantity" - NEW."quantity"
    WHERE "id" = NEW."product_id";
END;

-- creating trigger "counting_total_amount_and_adding_bonuses"
CREATE TRIGGER "counting_total_amount_and_adding_bonuses"
AFTER INSERT ON "order_items"
FOR EACH ROW
BEGIN
    UPDATE "orders"
    SET "total_amount" = (
        SELECT COALESCE(SUM("quantity" * "unit_price"), 0)
        FROM "order_items"
        WHERE "order_id" = NEW."order_id"
    )
    WHERE "id" = NEW."order_id";

    UPDATE "customers"
    SET "bonus_points" = (SELECT COALESCE("bonus_points", 0) + (NEW."unit_price" * NEW."quantity" * 0.11))
    WHERE "id" = (
        SELECT "customer_id"
        FROM "orders"
        WHERE "id" = NEW."order_id"
    );
END;




