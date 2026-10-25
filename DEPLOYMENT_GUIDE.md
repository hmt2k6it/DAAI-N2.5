# HƯỚNG DẪN TRIỂN KHAI THỦ CÔNG 100% TRÊN MÁY KHÁC (MANUAL DEPLOYMENT GUIDE)
> **Đồ án**: Phân tích Toàn cảnh Doanh thu theo Địa giới | **Mã nhóm**: DAAI-N2.5  
> **Kiến trúc**: SQL Server (Star Schema) ➔ SSAS Tabular (VertiPaq In-Memory RAM) ➔ Power BI Desktop (Live Connection)

Tài liệu này hướng dẫn **chi tiết từng bước bằng tay (Manual)**, thao tác trực tiếp trên giao diện đồ họa (GUI) của các công cụ chính thức (**SSMS, Visual Studio, Jupyter/VS Code, Power BI Desktop**), không sử dụng script tự động, giúp bất kỳ ai (thành viên nhóm, giảng viên, hội đồng chấm thi) cũng có thể tự cài đặt và vận hành hệ thống từ con số 0 trên máy tính mới.

---

## 🛠️ PHẦN 1: CHUẨN BỊ MÔI TRƯỜNG & CÀI ĐẶT PHẦN MỀM

Trước khi bắt đầu, hãy đảm bảo máy tính đã cài đặt đầy đủ các phần mềm sau:

### 1. Microsoft SQL Server (Bản Developer hoặc Enterprise)
* Tải bản Developer miễn phí từ trang chủ Microsoft.
* Cài đặt tính năng **Database Engine Services**.
* Chế độ xác thực: Chọn **Windows Authentication** hoặc **Mixed Mode** (nhớ mật khẩu tài khoản `sa` nếu chọn Mixed Mode).

### 2. SQL Server Analysis Services (SSAS) - Chế độ Tabular Mode
* ⚠️ **LƯU Ý CỰC KỲ QUAN TRỌNG**: 
  * Khi cài đặt SSAS (trong SQL Server Setup), tại màn hình **Analysis Services Configuration**:
  * Phải tích chọn: 🔘 **Tabular Mode** *(Mặc định SQL Server có thể chọn Multidimensional Mode, nếu chọn sai sẽ không mở được mô hình `Model.bim`)*.
  * Tại ô bên dưới, nhấn nút **Add Current User** để cấp quyền quản trị cao nhất (Server Administrator) cho tài khoản Windows của bạn.

### 3. SQL Server Management Studio (SSMS)
* Cài đặt SSMS (phiên bản v18, v19 hoặc v20) để quản lý CSDL SQL Server và SSAS.

### 4. Visual Studio (2019 hoặc 2022) + SSDT Extension
* Cài đặt Visual Studio (Community miễn phí).
* Mở Visual Studio ➔ Menu **Extensions** ➔ **Manage Extensions** ➔ Tìm kiếm và cài đặt extension: **Microsoft Analysis Services Projects**.
* *(Khởi động lại Visual Studio sau khi cài đặt extension)*.

### 5. Python 3.10+ & ODBC Driver
* Tải và cài đặt **Python 3.10+** (nhớ tích chọn ☑️ **Add Python to PATH** khi cài đặt).
* Tải và cài đặt **Microsoft ODBC Driver 18 for SQL Server**.

### 6. Power BI Desktop
* Tải và cài đặt Microsoft Power BI Desktop (bản miễn phí mới nhất).

---

## 📋 PHẦN 2: QUY TRÌNH TRIỂN KHAI THỦ CÔNG CHI TIẾT (5 BƯỚC)

---

### BƯỚC 1: Tạo CSDL và Chạy Script DDL trên SQL Server (SSMS)

1. Mở **SQL Server Management Studio (SSMS)**.
2. Tại màn hình kết nối:
   * **Server type:** `Database Engine`
   * **Server name:** `localhost` (hoặc `.` hoặc tên máy của bạn).
   * **Authentication:** `Windows Authentication`
   * Nhấn **Connect**.
3. Tại cửa sổ *Object Explorer* bên trái:
   * Click chuột phải vào thư mục **Databases** ➔ Chọn **New Database...**
   * Ô **Database name:** Điền chính xác là `datawarehouse`.
   * Nhấn **OK**.
4. Mở file script Star Schema:
   * Trên thanh menu SSMS, chọn **File** ➔ **Open** ➔ **File...** (hoặc phím tắt `Ctrl + O`).
   * Điều hướng và chọn file: `DataWarehouse/SQL/StarSchema.sql`.
   * Đảm bảo ô chọn CSDL trên thanh công cụ đang chọn đúng `datawarehouse`.
   * Nhấn nút **Execute** (hoặc phím **F5**).
5. **Kiểm tra kết quả:**
   * Trong *Object Explorer*, mở rộng `Databases` ➔ `datawarehouse` ➔ `Tables`.
   * Bạn sẽ thấy đủ **2 bảng Fact** (`fact_orders`, `fact_order_items`) và **6 bảng Dimension** (`dim_date`, `dim_customer`, `dim_product`, `dim_business_unit`, `dim_geography`, `dim_waterfall`).

---

### BƯỚC 2: Cài Đặt Thư Viện & Chạy Pipeline ETL Nạp Dữ Liệu

1. Mở Command Prompt (`cmd`) hoặc PowerShell trên máy tính:
   * Cài đặt các thư viện cần thiết bằng lệnh:
     ```bash
     pip install pandas sqlalchemy pyodbc python-dotenv
     ```
2. Cấu hình file kết nối:
   * Mở file `DataWarehouse/ETL/.env` bằng Notepad hoặc VS Code.
   * Đảm bảo nội dung như sau:
     ```ini
     DB_SERVER=localhost
     DB_NAME=datawarehouse
     DB_DRIVER=ODBC Driver 18 for SQL Server
     DB_TRUSTED_CONNECTION=yes
     DB_TRUST_SERVER_CERTIFICATE=yes
     ```
   *(Nếu SQL Server của bạn đặt mật khẩu `sa`, hãy thêm 2 dòng: `DB_USER=sa` và `DB_PASSWORD=mật_khẩu_của_bạn`).*
3. Mở và chạy lần lượt 7 Notebooks trong thư mục `DataWarehouse/ETL/` bằng **VS Code** (hoặc Jupyter Notebook):
   * Mở file **`01_Load_Dim_Date.ipynb`** ➔ Nhấn **Run All** (hoặc chạy từng ô).
   * Mở file **`02_Load_Dim_Geography.ipynb`** ➔ Nhấn **Run All**.
   * Mở file **`03_Load_Dim_Customer.ipynb`** ➔ Nhấn **Run All**.
   * Mở file **`04_Load_Dim_Product.ipynb`** ➔ Nhấn **Run All**.
   * Mở file **`05_Load_Dim_Business_Unit.ipynb`** ➔ Nhấn **Run All**.
   * Mở file **`06_Load_Fact_Orders.ipynb`** ➔ Nhấn **Run All** *(Chờ nạp ~646k dòng vào fact_orders)*.
   * Mở file **`07_Load_Fact_Order_Items.ipynb`** ➔ Nhấn **Run All** *(Chờ nạp ~714k dòng vào fact_order_items)*.
4. **Kiểm tra dữ liệu trong SSMS:**
   * Mở cửa sổ truy vấn mới (New Query) trên database `datawarehouse` và chạy:
     ```sql
     SELECT 'dim_date' AS TableName, COUNT(*) AS TotalRows FROM dbo.dim_date
     UNION ALL
     SELECT 'dim_geography', COUNT(*) FROM dbo.dim_geography
     UNION ALL
     SELECT 'dim_business_unit', COUNT(*) FROM dbo.dim_business_unit
     UNION ALL
     SELECT 'fact_orders', COUNT(*) FROM dbo.fact_orders
     UNION ALL
     SELECT 'fact_order_items', COUNT(*) FROM dbo.fact_order_items;
     ```
   * Kết quả trả về: `dim_geography` (~39,948), `dim_business_unit` (98), `fact_orders` (646,945), `fact_order_items` (714,669). Toàn bộ dữ liệu đã sẵn sàng!

---

### BƯỚC 3: Mở & Deploy Dự Án SSAS Tabular Bằng Visual Studio

1. Mở **Visual Studio** (2019 hoặc 2022).
2. Chọn **File** ➔ **Open** ➔ **Project/Solution...**
3. Điều hướng tới thư mục dự án và chọn file: `Olap/SSAS/SSAS.smproj`.
4. Trong cửa sổ **Solution Explorer** bên phải:
   * Nhấp đúp chuột vào file **`Model.bim`** để mở giao diện thiết kế mô hình Tabular.
   * *(Nếu xuất hiện hộp thoại Tabular Model Designer, chọn Workspace Database mặc định rồi nhấn OK)*.
5. **Kiểm tra chuỗi kết nối Data Source tới SQL Server:**
   * Trong cửa sổ *Tabular Model Explorer* (thường nằm cạnh Solution Explorer):
   * Mở rộng mục **Data Sources** ➔ Click đúp chuột vào kết nối SQL Server (ví dụ: `SqlServer localhost datawarehouse`).
   * Nhấn **Change Connection** ➔ Đảm bảo:
     * Server name: `localhost` (hoặc tên SQL Server của máy bạn).
     * Database name: `datawarehouse`.
     * Impersonation Information: Chọn **Service Account** (hoặc **Current User**).
   * Nhấn **Test Connection** để báo thành công.
6. **Cấu hình địa chỉ Server để Deploy:**
   * Trong cửa sổ *Solution Explorer*, **click chuột phải vào tên Project `SSAS`** (icon màu xanh dương) ➔ Chọn **Properties**.
   * Tại menu bên trái, chọn thẻ **Deployment**:
     * Mục **Processing Option**: Chọn `Do Not Process` (hoặc `Default`).
     * Mục **Server**: Điền `localhost` (hoặc `localhost:2383` nếu máy có instance riêng).
     * Mục **Database**: Điền `DAAI_OLAP`.
   * Nhấn nút **Apply** ➔ **OK**.
7. **Thực hiện Deploy mô hình lên SSAS:**
   * Click chuột phải vào tên Project `SSAS` ➔ Chọn **Deploy**.
   * Cửa sổ *Deploy* sẽ hiện ra và chạy kiểm tra Metadata:
     * Chờ các dòng trạng thái chạy: Deploying metadata...
     * Khi xuất hiện dòng: **Deploy Succeeded** (màu xanh lá) ➔ Nhấn **Close**.
   * *(Lúc này Metadata của CSDL DAAI_OLAP đã được tạo thành công trên dịch vụ SSAS)*.

---

### BƯỚC 4: Process Full Nạp Dữ Liệu vào VertiPaq RAM (Bằng SSMS)

1. Mở **SSMS** (nếu đang mở thì giữ nguyên).
2. Nhấn nút **Connect** (hoặc menu *File ➔ Connect Object Explorer...*):
   * **Server type:** ⚠️ Chọn **Analysis Services** (khác với Database Engine ban đầu).
   * **Server name:** Điền `localhost` (hoặc `localhost:2383`).
   * **Authentication:** `Windows Authentication`.
   * Nhấn **Connect**.
3. Trong cửa sổ *Object Explorer*:
   * Mở rộng thư mục **Databases**.
   * Bạn sẽ nhìn thấy database **`DAAI_OLAP`** (có icon hình bảng tính Tabular).
4. **Kích hoạt nạp dữ liệu vào RAM:**
   * Click chuột phải vào database **`DAAI_OLAP`** ➔ Chọn **Process Database**.
   * Cửa sổ *Process Database - DAAI_OLAP* sẽ hiện ra:
     * Tại cột **Mode**, click vào ô chọn và chuyển thành: **`Process Full`**.
   * Nhấn nút **OK** ở góc dưới.
5. Chờ hệ thống thực thi nạp dữ liệu:
   * Cửa sổ *Process Progress* sẽ hiển thị tiến trình nạp dữ liệu cho từng bảng Fact và Dimension từ SQL Server vào bộ nhớ nén VertiPaq.
   * Khi tất cả trạng thái chuyển sang **Success** ➔ Nhấn nút **Close**.
   * 👉 *Bây giờ toàn bộ 41 Measures, 5 Display Folders và hàng triệu bản ghi đã nằm trong RAM của SSAS!*

---

### BƯỚC 5: Mở Dashboard & Kiểm Tra Trên Power BI Desktop

1. Khởi động **Power BI Desktop**.
2. Chọn **File** ➔ **Open report** ➔ **Browse reports**.
3. Chọn file báo cáo: `Dashboard/DB_DEMODiret.pbix`.
4. Power BI Desktop sẽ tự động mở file và kết nối Live Connection tới SSAS Server `localhost` Database `DAAI_OLAP`.
5. **Cách xử lý nếu máy mới có tên Server khác `localhost`:**
   * Nếu máy mới dùng tên instance riêng (ví dụ `DESKTOP-XYZ\TABULAR`), Power BI có thể hiện bảng cảnh báo kết nối.
   * Bạn chỉ cần thao tác thủ công:
     1. Nhìn xuống **góc dưới cùng bên phải** của màn hình Power BI, bạn sẽ thấy dòng chữ: `Connected live to the Analysis Services database: ...`.
     2. Hoặc vào menu trên cùng: Thẻ **Home** ➔ Nhấn nút **Transform data** ➔ Chọn **Data source settings**.
     3. Chọn kết nối hiện tại ➔ Nhấn **Change Source...**
     4. Tại ô **Server**, điền lại tên SSAS Server máy bạn (ví dụ: `localhost` hoặc `.` hoặc `tên_máy`).
     5. Ô **Database**, điền: `DAAI_OLAP`.
     6. Nhấn **OK**.
6. **Kiểm tra toàn bộ 5 trang Dashboard:**
   * **PS1:** Doanh thu thuần, gộp, hoàn trả, Waterfall và bảng ma trận phân loại thị trường Likert 4 mức.
   * **PS2:** Chênh lệch sản lượng, tỷ lệ đổi trả, hệ số phân cực sức mua 1.67x và khoảng cách Gap sản lượng.
   * **PS3:** Đánh giá AOV, ARPU, tần suất mua lặp lại và cây phân rã nguyên nhân hoàn tiền.
   * **PS4:** Ma trận BCG 4 góc phần tư (⭐ Ngôi sao, 🐮 Bò sữa, ❓ Dấu hỏi, 🐕 Chó mực) và Đề xuất phân bổ nguồn lực.
   * **PS5:** Đánh giá 98 đơn vị kinh doanh theo 2 trụ cột (ARPU + AOV), xếp hạng và đề xuất chiến lược mạng lưới.

---

## 🎯 BẢNG CHECKLIST KIỂM TRA ĐẠT YÊU CẦU

| Hạng mục kiểm tra | Thao tác xác nhận | Trạng thái mong đợi |
| :--- | :--- | :--- |
| **Dịch vụ SSAS** | Mở `services.msc`, tìm `SQL Server Analysis Services` | Status = `Running`, Startup Type = `Automatic` |
| **CSDL SQL Server** | Mở SSMS ➔ Database Engine ➔ `datawarehouse` | Có đủ 8 bảng: 2 fact, 6 dim |
| **CSDL SSAS Tabular** | Mở SSMS ➔ Analysis Services ➔ `DAAI_OLAP` | Có đủ 41 measures phân vào 5 display folder |
| **Dữ liệu VertiPaq** | Chạy New DAX Query trong SSMS: `EVALUATE TOPN(5, fact_orders)` | Trả về dữ liệu ngay tức thì (dưới 0.1s) |
| **Power BI Dashboard** | Mở `DB_DEMODiret.pbix` chuyển qua 5 trang PS1 - PS5 | Tất cả các visual tải số liệu đầy đủ, 0 báo lỗi |

---
*Tài liệu triển khai thủ công dự án DAAI-N2.5 hoàn tất!*
