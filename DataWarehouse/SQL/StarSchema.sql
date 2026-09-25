-- =========================================================================
-- CREATE SCHEMA CHO DATA WAREHOUSE - DAAI-N2.5
-- DBMS: SQL Server / PostgreSQL / MySQL đều hỗ trợ cú pháp này
-- =========================================================================

-- -------------------------------------------------------------------------
-- 1. TẠO CÁC BẢNG DIMENSION (CHỨA THUỘC TÍNH MÔ TẢ)
-- -------------------------------------------------------------------------

CREATE TABLE DIM_DATE (
    date_key INT PRIMARY KEY,
    full_date DATE,
    day INT,
    month INT,
    quarter INT,
    year INT
);

CREATE TABLE DIM_GEOGRAPHY (
    geography_key INT PRIMARY KEY,
    zip VARCHAR(20),
    district VARCHAR(100),
    city VARCHAR(100),
    region VARCHAR(100)
);

CREATE TABLE DIM_CUSTOMER (
    customer_key INT PRIMARY KEY,
    customer_id VARCHAR(50),
    signup_date DATE,
    gender VARCHAR(20),
    age_group VARCHAR(50),
    acquisition_channel VARCHAR(50)
);

CREATE TABLE DIM_EMPLOYEE (
    employee_key INT PRIMARY KEY,
    sales_employee_id VARCHAR(50),
    sales_employee_name VARCHAR(100)
);

CREATE TABLE DIM_PAYMENT_METHOD (
    payment_method_key INT PRIMARY KEY,
    payment_method VARCHAR(50)
);

CREATE TABLE DIM_PRODUCT (
    product_key INT PRIMARY KEY,
    product_id VARCHAR(50),
    product_name VARCHAR(255),
    category VARCHAR(100),
    segment VARCHAR(100),
    size VARCHAR(50),
    color VARCHAR(50),
    list_price DECIMAL(18,2),
    cogs DECIMAL(18,2)
);

CREATE TABLE DIM_PROMOTION (
    promotion_key INT PRIMARY KEY,
    promo_id VARCHAR(50),
    promo_name VARCHAR(255),
    promo_type VARCHAR(100)
);

CREATE TABLE DIM_RETURN_REASON (
    return_reason_key INT PRIMARY KEY,
    return_reason VARCHAR(255)
);

-- -------------------------------------------------------------------------
-- 2. TẠO CÁC BẢNG FACT (CHỨA CHỈ SỐ ĐO LƯỜNG VÀ KHÓA NGOẠI)
-- -------------------------------------------------------------------------

-- NGÔI SAO 1: DOANH THU THEO ĐƠN HÀNG
CREATE TABLE FACT_ORDERS (
    order_key INT PRIMARY KEY,
    order_id VARCHAR(50), -- Degenerate dimension
    
    -- Foreign Keys
    order_date_key INT REFERENCES DIM_DATE(date_key),
    customer_key INT REFERENCES DIM_CUSTOMER(customer_key),
    geography_key INT REFERENCES DIM_GEOGRAPHY(geography_key),
    employee_key INT REFERENCES DIM_EMPLOYEE(employee_key),
    payment_method_key INT REFERENCES DIM_PAYMENT_METHOD(payment_method_key),
    
    -- Attributes & Measures
    order_status VARCHAR(50),
    installments INT,
    payment_value DECIMAL(18,2), -- Gross Revenue
    refund_amount DECIMAL(18,2),
    net_revenue DECIMAL(18,2),
    order_count INT,
    returned_order_count INT
);

-- NGÔI SAO 2: SẢN LƯỢNG THEO SẢN PHẨM TRONG ĐƠN
CREATE TABLE FACT_ORDER_ITEMS (
    item_key INT PRIMARY KEY,
    item_id VARCHAR(50),
    order_id VARCHAR(50),
    
    -- Foreign Keys
    order_date_key INT REFERENCES DIM_DATE(date_key),
    geography_key INT REFERENCES DIM_GEOGRAPHY(geography_key),
    product_key INT REFERENCES DIM_PRODUCT(product_key),
    promotion_key_1 INT REFERENCES DIM_PROMOTION(promotion_key),
    promotion_key_2 INT REFERENCES DIM_PROMOTION(promotion_key),
    
    -- Measures
    purchased_quantity INT,
    returned_quantity INT,
    net_quantity INT,
    unit_price DECIMAL(18,2),
    discount_amount DECIMAL(18,2),
    gross_item_amount DECIMAL(18,2),
    item_sales_amount DECIMAL(18,2)
);

-- NGÔI SAO 3: HOÀN TRẢ CHI TIẾT
CREATE TABLE FACT_RETURNS (
    return_key INT PRIMARY KEY,
    return_id VARCHAR(50),
    order_id VARCHAR(50),
    
    -- Foreign Keys
    return_date_key INT REFERENCES DIM_DATE(date_key),
    geography_key INT REFERENCES DIM_GEOGRAPHY(geography_key),
    product_key INT REFERENCES DIM_PRODUCT(product_key),
    return_reason_key INT REFERENCES DIM_RETURN_REASON(return_reason_key),
    
    -- Measures
    return_quantity INT,
    refund_amount DECIMAL(18,2)
);
