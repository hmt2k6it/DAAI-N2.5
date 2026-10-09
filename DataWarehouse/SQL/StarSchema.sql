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

-- -------------------------------------------------------------------------
-- 2. TẠO CÁC BẢNG FACT (CHỨA CHỈ SỐ ĐO LƯỜNG VÀ KHÓA NGOẠI)
-- -------------------------------------------------------------------------

-- NGÔI SAO 1: DOANH THU THEO ĐƠN HÀNG
CREATE TABLE FACT_ORDERS (
    order_key INT PRIMARY KEY,
    order_id VARCHAR(50), -- Degenerate dimension (Mã đơn hàng)
    
    -- Foreign Keys
    order_date_key INT REFERENCES DIM_DATE(date_key),
    customer_key INT REFERENCES DIM_CUSTOMER(customer_key),
    geography_key INT REFERENCES DIM_GEOGRAPHY(geography_key),
    
    -- Attributes & Base Measures (Doanh thu thuần net_revenue sẽ do tầng OLAP tự tính toán)
    order_status VARCHAR(50),
    payment_value DECIMAL(18,2), -- Gross Revenue (Doanh thu gộp)
    refund_amount DECIMAL(18,2)  -- Refund Amount (Tiền hoàn trả)
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
    
    -- Measures
    return_quantity INT,
    refund_amount DECIMAL(18,2)
);

-- -------------------------------------------------------------------------
-- 3. TẠO BẢNG DATA MART (GOLD LAYER - PS5: ĐÁNH GIÁ ĐƠN VỊ KINH DOANH)
-- -------------------------------------------------------------------------

CREATE TABLE GOLD_UNIT_KPI (
    unit_kpi_key INT PRIMARY KEY,
    unit_id VARCHAR(50),
    unit_type VARCHAR(50),
    region VARCHAR(100),
    city VARCHAR(100),
    district VARCHAR(100),
    
    -- Thống kê quy mô
    total_customers INT,
    served_customers INT,
    invoice_count INT,
    customer_percentile_in_city DECIMAL(5,2),
    customer_rank_in_city INT,
    
    -- Doanh thu & Chỉ số trung bình
    gross_revenue DECIMAL(18,2),
    refund_amount DECIMAL(18,2),
    net_revenue DECIMAL(18,2),
    revenue_per_customer DECIMAL(18,2),
    revenue_per_invoice DECIMAL(18,2),
    customer_activation_pct DECIMAL(5,2),
    
    -- Điểm thành phần KPI (chuẩn hóa thang điểm 0 - 100)
    net_revenue_score DECIMAL(5,2),
    served_customers_score DECIMAL(5,2),
    revenue_per_customer_score DECIMAL(5,2),
    revenue_per_invoice_score DECIMAL(5,2),
    customer_activation_pct_score DECIMAL(5,2),
    
    -- Điểm tổng hợp, Xếp hạng & Đánh giá
    kpi_score DECIMAL(5,2),
    overall_rank INT,
    performance_group VARCHAR(50),
    recommendation VARCHAR(150)
);
