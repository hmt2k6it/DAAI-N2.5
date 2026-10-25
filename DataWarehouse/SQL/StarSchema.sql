-- =========================================================================
-- CREATE SCHEMA CHO DATA WAREHOUSE - DAAI-N2.5 (CLEAN STAR SCHEMA)
-- DBMS: Microsoft SQL Server 2025 / SSAS Tabular Ready
-- Kien truc: 2 Bang Fact chinh (Order & Item grain) + 5 Bang Dimension chuan
-- =========================================================================

USE [datawarehouse];
GO

-- -------------------------------------------------------------------------
-- 0. XOA CAC RANG BUOC VA BANG CU NEU DA TON TAI (DE TRUONG HOP CHAY LAI AN TOAN)
-- -------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.fact_order_items', N'U') IS NOT NULL DROP TABLE dbo.fact_order_items;
IF OBJECT_ID(N'dbo.fact_orders', N'U') IS NOT NULL DROP TABLE dbo.fact_orders;
IF OBJECT_ID(N'dbo.dim_geography', N'U') IS NOT NULL DROP TABLE dbo.dim_geography;
IF OBJECT_ID(N'dbo.dim_customer', N'U') IS NOT NULL DROP TABLE dbo.dim_customer;
IF OBJECT_ID(N'dbo.dim_product', N'U') IS NOT NULL DROP TABLE dbo.dim_product;
IF OBJECT_ID(N'dbo.dim_business_unit', N'U') IS NOT NULL DROP TABLE dbo.dim_business_unit;
IF OBJECT_ID(N'dbo.dim_date', N'U') IS NOT NULL DROP TABLE dbo.dim_date;
GO

-- -------------------------------------------------------------------------
-- 1. TAO CAC BANG DIMENSION (CHUA THUOC TINH MO TA)
-- -------------------------------------------------------------------------

-- 1.1. Chieu thoi gian (DIM_DATE)
CREATE TABLE dbo.dim_date (
    date_key INT NOT NULL,
    full_date DATE NULL,
    [day] INT NULL,
    [month] INT NULL,
    [quarter] INT NULL,
    [year] INT NULL,
    CONSTRAINT PK_dim_date PRIMARY KEY CLUSTERED (date_key)
);
GO

-- 1.2. Chieu khach hang (DIM_CUSTOMER)
CREATE TABLE dbo.dim_customer (
    customer_key INT NOT NULL,
    customer_id NVARCHAR(50) NULL,
    signup_date DATE NULL,
    gender NVARCHAR(20) NULL,
    age_group NVARCHAR(50) NULL,
    acquisition_channel NVARCHAR(50) NULL,
    CONSTRAINT PK_dim_customer PRIMARY KEY CLUSTERED (customer_key)
);
GO

-- 1.3. Chieu san pham (DIM_PRODUCT)
CREATE TABLE dbo.dim_product (
    product_key BIGINT NOT NULL,
    product_id NVARCHAR(100) NULL,
    product_name NVARCHAR(500) NULL,
    category NVARCHAR(100) NULL,
    segment NVARCHAR(100) NULL,
    size NVARCHAR(50) NULL,
    color NVARCHAR(50) NULL,
    price FLOAT NULL,
    cogs FLOAT NULL,
    CONSTRAINT PK_dim_product PRIMARY KEY CLUSTERED (product_key)
);
GO

-- 1.4. Chieu don vi kinh doanh (DIM_BUSINESS_UNIT - Phuc vu PS5)
CREATE TABLE dbo.dim_business_unit (
    unit_key INT NOT NULL,
    unit_id NVARCHAR(150) NOT NULL,
    unit_name NVARCHAR(150) NOT NULL,
    unit_type NVARCHAR(50) NOT NULL,
    region NVARCHAR(50) NOT NULL,
    city NVARCHAR(100) NOT NULL,
    district NVARCHAR(100) NOT NULL,
    kpi_score DECIMAL(5,2) NULL,
    overall_rank INT NULL,
    unit_performance_kpi NVARCHAR(50) NULL,
    recommendation NVARCHAR(100) NULL,
    CONSTRAINT PK_dim_business_unit PRIMARY KEY CLUSTERED (unit_key),
    CONSTRAINT UQ_dim_business_unit_unit_id UNIQUE (unit_id)
);
GO

-- 1.5. Chieu dia ly (DIM_GEOGRAPHY - Quan he voi DIM_BUSINESS_UNIT)
CREATE TABLE dbo.dim_geography (
    geography_key INT NOT NULL,
    zip NVARCHAR(20) NULL,
    district NVARCHAR(100) NULL,
    city NVARCHAR(100) NULL,
    region NVARCHAR(100) NULL,
    unit_key INT NULL,
    CONSTRAINT PK_dim_geography PRIMARY KEY CLUSTERED (geography_key),
    CONSTRAINT FK_dim_geography_business_unit FOREIGN KEY (unit_key) 
        REFERENCES dbo.dim_business_unit(unit_key)
);
GO

-- 1.6. Chieu giai doan Waterfall (DIM_WATERFALL - Phuc vu Bieu do Thac nuoc PS1)
CREATE TABLE dbo.dim_waterfall (
    stage_id INT NOT NULL,
    stage NVARCHAR(50) NOT NULL,
    sort_order INT NOT NULL,
    CONSTRAINT PK_dim_waterfall PRIMARY KEY CLUSTERED (stage_id)
);
GO

INSERT INTO dbo.dim_waterfall (stage_id, stage, sort_order)
VALUES 
(1, N'Gross Revenue', 1),
(2, N'(-) Hoàn Trả', 2);
GO

-- -------------------------------------------------------------------------
-- 2. TAO CAC BANG FACT (CHUA CHI SO DO LUONG VA KHOA NGOAI)
-- -------------------------------------------------------------------------

-- NGOI SAO 1: DOANH THU & GIAO DICH DON HANG (FACT_ORDERS)
-- Phuc vu: PS1 (Doanh thu), PS3 (Chat luong & Tien hoan), PS4 (Dia ly & Ma tran BCG), PS5 (Hieu qua Don vi kinh doanh)
CREATE TABLE dbo.fact_orders (
    order_key BIGINT NOT NULL,
    order_id NVARCHAR(100) NULL,
    order_date_key INT NULL,
    customer_key INT NULL,
    geography_key INT NULL,
    unit_key INT NULL,
    order_status NVARCHAR(50) NULL,
    payment_value FLOAT NULL,       -- Doanh thu gop (Gross Revenue)
    refund_amount FLOAT NULL,       -- Tien hoan tra tich hop tu returns_silver
    CONSTRAINT PK_fact_orders PRIMARY KEY CLUSTERED (order_key),
    CONSTRAINT FK_fact_orders_date FOREIGN KEY (order_date_key) REFERENCES dbo.dim_date(date_key),
    CONSTRAINT FK_fact_orders_customer FOREIGN KEY (customer_key) REFERENCES dbo.dim_customer(customer_key),
    CONSTRAINT FK_fact_orders_geography FOREIGN KEY (geography_key) REFERENCES dbo.dim_geography(geography_key),
    CONSTRAINT FK_fact_orders_unit FOREIGN KEY (unit_key) REFERENCES dbo.dim_business_unit(unit_key)
);
GO

-- NGOI SAO 2: SAN LUONG CHI TIET THEO SAN PHAM TRONG DON (FACT_ORDER_ITEMS)
-- Phuc vu: PS2 (Co cau va Xep hang San luong mua/tra theo danh muc san pham)
CREATE TABLE dbo.fact_order_items (
    item_key BIGINT NOT NULL,
    item_id NVARCHAR(100) NULL,
    order_id NVARCHAR(100) NULL,
    order_date_key INT NULL,
    geography_key INT NULL,
    product_key BIGINT NULL,
    purchased_quantity BIGINT NULL, -- So luong mua
    returned_quantity BIGINT NULL,  -- So luong tra
    CONSTRAINT PK_fact_order_items PRIMARY KEY CLUSTERED (item_key),
    CONSTRAINT FK_fact_order_items_date FOREIGN KEY (order_date_key) REFERENCES dbo.dim_date(date_key),
    CONSTRAINT FK_fact_order_items_geography FOREIGN KEY (geography_key) REFERENCES dbo.dim_geography(geography_key),
    CONSTRAINT FK_fact_order_items_product FOREIGN KEY (product_key) REFERENCES dbo.dim_product(product_key)
);
GO

-- -------------------------------------------------------------------------
-- 3. TAO INDEX DE TOI UU PERFORMANCE TRUY VAN VA JOIN (SUB-SECOND LATENCY)
-- -------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_fact_orders_date ON dbo.fact_orders(order_date_key);
CREATE NONCLUSTERED INDEX IX_fact_orders_customer ON dbo.fact_orders(customer_key);
CREATE NONCLUSTERED INDEX IX_fact_orders_geography ON dbo.fact_orders(geography_key);
CREATE NONCLUSTERED INDEX IX_fact_orders_unit ON dbo.fact_orders(unit_key);

CREATE NONCLUSTERED INDEX IX_fact_order_items_date ON dbo.fact_order_items(order_date_key);
CREATE NONCLUSTERED INDEX IX_fact_order_items_product ON dbo.fact_order_items(product_key);
CREATE NONCLUSTERED INDEX IX_fact_order_items_geography ON dbo.fact_order_items(geography_key);
GO

PRINT 'Star Schema DDL executed successfully on SQL Server!';
GO
