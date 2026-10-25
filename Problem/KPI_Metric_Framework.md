# HỆ THỐNG MEASURE - METRIC - KPI & THANG ĐO LIKERT (PS1 - PS5)
> **Đồ án**: Phân tích Toàn cảnh Doanh thu theo Địa giới | **Mô hình**: SSAS Tabular OLAP + Power BI Live Connection  
> **Nguyên tắc**: Chuẩn hóa theo hướng dẫn của Thầy (Measure ➔ Metric ➔ KPI ➔ Thang đo Likert). Cấp Vùng dùng thang 3 mức, Cấp Tỉnh/Huyện dùng thang 4 mức theo Tứ phân vị Python (Q1, Q2, Q3) loại bỏ mức trung lập.

---

## 1. Problem Statement 1: Ánh xạ và Tổng hợp Doanh thu theo Địa giới
* **Mục tiêu**: Đánh giá quy mô doanh thu để **khoanh vùng thị trường trọng điểm phát triển mạnh nhất**.

### 📐 Danh mục Measure - Metric - KPI
| Cấp độ | Tên chỉ số | Ký hiệu / DAX | Công thức | Thang đo Likert & Đánh giá |
| :--- | :--- | :--- | :--- | :--- |
| **Base Measure** | Doanh thu gộp | `Gross Revenue` | `SUM(payment_value)` | Thước đo dòng tiền thô thu vào |
| **Base Measure** | Tiền hoàn trả | `Refund Amount` | `SUM(refund_amount)` | Thước đo giá trị hàng bị hoàn trả |
| **Metric** | Doanh thu thuần | `Net Revenue` | `[Gross Revenue] - [Refund Amount]` | Doanh thu thực nhận sau hoàn trả |
| **Metric** | Tỷ lệ hoàn tiền (%) | `Refund Value Pct` | `DIVIDE([Refund Amount], [Gross Revenue], 0)` | Tỷ lệ hao hụt doanh thu (Toàn quốc 3.81%) |
| **KPI Cốt Lõi** | **Tỷ trọng doanh thu (%)** | `Revenue Share Pct KPI` | `DIVIDE([Net Revenue], CALCULATE([Net Revenue], ALLSELECTED()), 0)` | Thước đo tỷ trọng đóng góp dòng tiền doanh thu theo cấp địa giới |
| **Thang đo Likert** | **Phân nhóm doanh thu** *(Thang đo cho KPI `Revenue Share Pct KPI`)* | `Revenue Group` | `SWITCH(...)` | **Thang đo Likert đánh giá cho KPI Tỷ trọng doanh thu (`Revenue Share Pct KPI`):**<br><br>**• Cấp Vùng (Thang 3 mức):**<br>- `>= 35%` (East 46.52%): **Cao**<br>- `25% - 35%` (Central 30.07%): **Trung bình**<br>- `< 25%` (West 23.42%): **Thấp**<br><br>**• Cấp Tỉnh 42 City (Thang 4 mức Tứ phân vị chuẩn xác):**<br>- `>= 3.24% (>= Q3 ~417.4M)`: **4. Xuất sắc** *(Khoanh vùng đúng 11 tỉnh trọng điểm: Sơn Tây, Nam Định, Thái Nguyên, Hà Nội, Phủ Lý, Ninh Bình, Hải Phòng, Hạ Long, Việt Trì, Bắc Giang, Bắc Ninh)*<br>- `2.48% - 3.24% (Q2 - Q3 ~319.1M - 417.4M)`: **3. Tốt** *(10 tỉnh)*<br>- `1.53% - 2.48% (Q1 - Q2 ~197.5M - 319.1M)`: **2. Trung bình** *(11 tỉnh)*<br>- `< 1.53% (< Q1 ~197.5M)`: **1. Thấp** *(10 tỉnh: Rạch Giá, Biên Hòa, Cần Thơ,...)*<br><br>**• Cấp Huyện 534 District (Thang 4 mức):**<br>- `>= 0.228% (>= Q3 ~29.2M)`: **4. Xuất sắc**<br>- `0.178% - 0.227% (Q2 - Q3 ~22.9M - 29.2M)`: **3. Tốt**<br>- `0.141% - 0.178% (Q1 - Q2 ~18.1M - 22.9M)`: **2. Trung bình**<br>- `< 0.141% (< Q1 ~18.1M)`: **1. Thấp** |

---

## 2. Problem Statement 2: So sánh Chênh lệch Sản lượng Tiêu thụ
* **Mục tiêu**: Đánh giá mức độ hấp thụ sản phẩm vật lý và **so sánh sự chênh lệch sức mua giữa các vùng địa giới**.

### 📐 Danh mục Measure - Metric - KPI
| Cấp độ | Tên chỉ số | Ký hiệu / DAX | Công thức | Thang đo Likert & Đánh giá |
| :--- | :--- | :--- | :--- | :--- |
| **Base Measure** | Tổng sản phẩm mua | `Purchased Qty` | `SUM(purchased_quantity)` | Thước đo sản lượng xuất kho |
| **Base Measure** | Tổng sản phẩm trả | `Returned Qty` | `SUM(returned_quantity)` | Thước đo sản lượng đổi/trả |
| **Metric** | Sản lượng tiêu thụ thuần | `Net Quantity` | `[Purchased Qty] - [Returned Qty]` | Khối lượng hàng hóa thị trường thực tế hấp thụ |
| **Metric** | Tỷ lệ đổi trả sản phẩm (%) | `Return Qty Rate Pct` | `DIVIDE([Returned Qty], [Purchased Qty], 0)` | Tỷ lệ hao hụt hàng hóa vật lý (Toàn quốc ~3.9%) |
| **Metric** | Chênh lệch sản lượng tuyệt đối | `Quantity Gap Abs` | `Net_Quantity(i) - Net_Quantity(Top 1)` | Khoảng cách số lượng sản phẩm so với đơn vị dẫn đầu |
| **Metric** | Chênh lệch sản lượng tương đối (%) | `Quantity Gap Pct` | `DIVIDE([Quantity Gap Abs], Net_Quantity(Top 1), 0)` | Tỷ lệ thụt lùi sản lượng so với đơn vị dẫn đầu |
| **Metric Phụ** | Chỉ số phân cực sức mua | `Quantity Disparity Index`| `Max(Net Quantity) / Min(Net Quantity)` | Hệ số lệch pha sức mua: Cấp Vùng **1.67x**, Cấp Tỉnh **2.47x** |
| **KPI Cốt Lõi** | **Tỷ trọng sản lượng thuần (%)** | `Quantity Share Pct KPI` | `DIVIDE([Net Quantity], CALCULATE([Net Quantity], ALLSELECTED()), 0)` | Thước đo tỷ trọng hấp thụ sản phẩm vật lý theo cấp địa giới |
| **Thang đo Likert** | **Phân nhóm sản lượng** *(Thang đo cho KPI `Quantity Share Pct KPI`)* | `Quantity Group` | `SWITCH(...)` | **Thang đo Likert đánh giá cho KPI Tỷ trọng sản lượng (`Quantity Share Pct KPI`):**<br><br>**• Cấp Vùng (Thang 3 mức):**<br>- `>= 35%` (East 44.9%): **Cao** *(Vùng quán quân sản lượng)*<br>- `28% - 35%` (Central 28.2%): **Trung bình**<br>- `< 28%` (West 26.9%): **Thấp**<br><br>**• Cấp Tỉnh 42 City (Thang 4 mức Tứ phân vị chuẩn xác):**<br>- `>= 3.16% (>= Q3 ~83,346 sp)`: **4. Xuất sắc** *(Top 11 tỉnh dẫn đầu)*<br>- `2.35% - 3.16% (Q2 - Q3 ~61,868 - 83,346 sp)`: **3. Tốt** *(10 tỉnh)*<br>- `1.77% - 2.35% (Q1 - Q2 ~46,549 - 61,868 sp)`: **2. Trung bình** *(11 tỉnh)*<br>- `< 1.77% (< Q1 ~46,549 sp)`: **1. Thấp** *(10 tỉnh: Rạch Giá, Biên Hòa, Cần Thơ,...)*<br><br>**• Cấp Huyện 534 District (Thang 4 mức):**<br>- `>= 0.228% (>= Q3 ~6,012 sp)`: **4. Xuất sắc**<br>- `0.175% - 0.228% (Q2 - Q3 ~4,613 - 6,012 sp)`: **3. Tốt**<br>- `0.137% - 0.175% (Q1 - Q2 ~3,624 - 4,613 sp)`: **2. Trung bình**<br>- `< 0.137% (< Q1 ~3,624 sp)`: **1. Thấp** |

---

## 3. Problem Statement 3: Thẩm định Hiệu quả Chiến lược Thị trường
* **Mục tiêu**: Đánh giá chất lượng tệp khách hàng, chất lượng giao dịch và rủi ro hoàn tiền làm cơ sở **thẩm định chiến lược phát triển thị trường theo cấp địa giới**.

### 📐 Danh mục Measure & Metric
| Cấp độ | Tên chỉ số | Ký hiệu / DAX | Công thức | Ý nghĩa nghiệp vụ |
| :--- | :--- | :--- | :--- | :--- |
| **Base Measure** | Tổng số đơn hàng | `Order Count` | `DISTINCTCOUNT(order_id)` | Quy mô giao dịch toàn hệ thống |
| **Base Measure** | Tổng số khách hàng | `Customer Count` | `DISTINCTCOUNT(customer_key)` | Quy mô tệp khách hàng tiếp cận được |
| **Base Measure** | Tổng đơn hoàn trả | `Returned Order Count` | `CALCULATE(DISTINCTCOUNT(order_id), refund > 0)` | Số lượng giao dịch phát sinh lỗi hoàn tiền |
| **Metric** | Tỷ lệ đơn hoàn trả (%) | `Returned Order Pct` | `DIVIDE([Returned Order Count], [Order Count], 0)` | Tỷ lệ phát sinh lỗi/trả hàng vận hành |
| **KPI 1** | **Giá trị trung bình đơn hàng** | `AOV` | `DIVIDE([Net Revenue], [Order Count], 0)` | Quy mô giá trị tiền tệ của 1 giao dịch |
| **Thang đo Likert 1** | **Phân nhóm giá trị đơn** | `AOV Group` | `SWITCH(...)` | Thang đo Likert (Vùng 3 mức; Tỉnh & Huyện 4 mức tứ phân vị) |
| **KPI 2** | **Doanh thu trung bình / khách** | `ARPU` | `DIVIDE([Net Revenue], [Customer Count], 0)` | Mức chi tiêu trọn đời trung bình của 1 khách |
| **Thang đo Likert 2** | **Phân nhóm chi tiêu khách** | `ARPU Group` | `SWITCH(...)` | Thang đo Likert (Vùng 3 mức; Tỉnh & Huyện 4 mức tứ phân vị) |
| **KPI 3** | **Tần suất mua hàng trung bình** | `Orders Per Customer` | `DIVIDE([Order Count], [Customer Count], 0)` | Số lần quay lại mua hàng của 1 khách hàng |
| **Thang đo Likert 3** | **Phân nhóm độ gắn kết** | `Orders Per Customer Group` | `SWITCH(...)` | Thang đo Likert (Vùng 3 mức; Tỉnh & Huyện 4 mức tứ phân vị) |

### 🎯 Thang đo Likert phân cấp (Region, City, District) cho 3 KPI Cốt Lõi

#### 1. KPI 1: Giá trị trung bình đơn hàng (`AOV`) ➔ Thang đo: `AOV Group`
* **• Cấp Vùng Region (Thang 3 mức):**
  * `>= 24,000 ₫`: **Cao** *(Miền Trung: 24,556 ₫ - Dẫn đầu chất lượng đơn hàng)*
  * `22,000 - 24,000 ₫`: **Trung bình** *(Miền Đông: 23,791 ₫)*
  * `< 22,000 ₫`: **Thấp** *(Miền Tây: 21,003 ₫ - Cần đẩy mạnh bán chéo / combo)*
* **• Cấp Tỉnh 42 City (Thang 4 mức Tứ phân vị):**
  * `AOV >= 24,520 ₫ (>= Q3)`: **4. Xuất sắc** | `23,880 - 24,520 ₫ (Q2 - Q3)`: **3. Tốt**
  * `21,240 - 23,880 ₫ (Q1 - Q2)`: **2. Trung bình** | `< 21,240 ₫ (< Q1)`: **1. Thấp**
* **• Cấp Huyện 534 District (Thang 4 mức Tứ phân vị):**
  * `AOV >= 24,822 ₫ (>= Q3)`: **4. Xuất sắc** | `23,730 - 24,822 ₫ (Q2 - Q3)`: **3. Tốt**
  * `22,548 - 23,730 ₫ (Q1 - Q2)`: **2. Trung bình** | `< 22,548 ₫ (< Q1)`: **1. Thấp**

#### 2. KPI 2: Doanh thu trung bình trên mỗi khách hàng (`ARPU`) ➔ Thang đo: `ARPU Group`
* **• Cấp Vùng Region (Thang 3 mức):**
  * `>= 180,000 ₫`: **Cao** *(Miền Tây: 211,404 ₫ - Khách hàng chi tiêu trọn đời cao nhất)*
  * `135,000 - 180,000 ₫`: **Trung bình** *(Miền Đông: 139,026 ₫)*
  * `< 135,000 ₫`: **Thấp** *(Miền Trung: 131,846 ₫)*
* **• Cấp Tỉnh 42 City (Thang 4 mức Tứ phân vị):**
  * `ARPU >= 224,570 ₫ (>= Q3)`: **4. Xuất sắc** | `160,780 - 224,570 ₫ (Q2 - Q3)`: **3. Tốt**
  * `152,900 - 160,780 ₫ (Q1 - Q2)`: **2. Trung bình** | `< 152,900 ₫ (< Q1)`: **1. Thấp**
* **• Cấp Huyện 534 District (Thang 4 mức Tứ phân vị):**
  * `ARPU >= 180,327 ₫ (>= Q3)`: **4. Xuất sắc** | `139,122 - 180,327 ₫ (Q2 - Q3)`: **3. Tốt**
  * `114,072 - 139,122 ₫ (Q1 - Q2)`: **2. Trung bình** | `< 114,072 ₫ (< Q1)`: **1. Thấp**

#### 3. KPI 3: Tần suất mua hàng trung bình (`Orders Per Customer`) ➔ Thang đo: `Orders Per Customer Group`
* **• Cấp Vùng Region (Thang 3 mức):**
  * `>= 8.0 đơn/khách`: **Cao** *(Miền Tây: 10.07 đơn/khách - Khách hàng cực kỳ trung thành)*
  * `5.5 - 8.0 đơn/khách`: **Trung bình** *(Miền Đông: 5.84 đơn/khách)*
  * `< 5.5 đơn/khách`: **Thấp** *(Miền Trung: 5.37 đơn/khách)*
* **• Cấp Tỉnh 42 City (Thang 4 mức Tứ phân vị):**
  * `>= 10.69 đơn (>= Q3)`: **4. Xuất sắc** | `6.69 - 10.69 đơn (Q2 - Q3)`: **3. Tốt**
  * `6.28 - 6.69 đơn (Q1 - Q2)`: **2. Trung bình** | `< 6.28 đơn (< Q1)`: **1. Thấp**
* **• Cấp Huyện 534 District (Thang 4 mức Tứ phân vị):**
  * `>= 7.50 đơn (>= Q3)`: **4. Xuất sắc** | `5.87 - 7.50 đơn (Q2 - Q3)`: **3. Tốt**
  * `4.79 - 5.87 đơn (Q1 - Q2)`: **2. Trung bình** | `< 4.79 đơn (< Q1)`: **1. Thấp**

---

## 4. Problem Statement 4: Phân tích Tăng trưởng & Định vị Thị phần (Ma trận BCG)
* **Mục tiêu**: Kết hợp quy mô thị phần và tốc độ tăng trưởng ở cả 3 cấp địa giới để **định vị thị trường và đề xuất phân bổ nguồn lực**.

### 📐 Danh mục Measure - Metric - KPI
| Cấp độ | Tên chỉ số | Ký hiệu / DAX | Công thức | Thang đo Likert & Đánh giá |
| :--- | :--- | :--- | :--- | :--- |
| **Base Measure** | Doanh thu thuần | `Net Revenue` | `[Gross Revenue] - [Refund Amount]` | Quy mô tiền tệ thực nhận làm gốc tính thị phần & tăng trưởng |
| **Metric** | Xếp hạng doanh thu | `Revenue Rank` | `RANKX(ALL(geo), [Net Revenue])` | Thứ hạng đóng góp doanh thu của địa bàn (#1 đến #N) |
| **KPI 1 (Trục X)** | **Tỷ trọng doanh thu (%)** | `Revenue Share Pct KPI` | `DIVIDE([Net Revenue], CALCULATE([Net Revenue], ALLSELECTED()), 0)` | Thước đo quy mô thị phần tiền tệ trên trục hoành Ma trận BCG |
| **Thang đo Likert 1** | **Phân nhóm doanh thu** *(Thang đo cho KPI `Revenue Share Pct KPI`)* | `Revenue Tier Group` | `SWITCH(...)` | **Thang đo & Đường cắt Phân nhóm Doanh thu (Trục X):**<br>- **Vùng**: Đường cắt Trung bình = 33.33% (~4.29 tỷ ₫) ➔ Doanh thu Cao vs Thấp<br>- **Tỉnh**: Thang 4 mức Tứ phân vị (Q1=197.5M, Q2=319.1M, Q3=417.4M) ➔ Đường cắt Trung vị Q2 = 319.1M (2.48%)<br>- **Huyện**: Thang 4 mức Tứ phân vị (Q1=18.1M, Q2=22.9M, Q3=29.2M) ➔ Đường cắt Trung vị Q2 = 22.9M (0.178%) |
| **KPI 2 (Trục Y)** | **Tốc độ tăng trưởng cùng kỳ (%)** | `YoY Growth Pct` | `DIVIDE([Net Revenue] - [PY Net], [PY Net], 0)` | Thước đo tốc độ mở rộng dòng tiền cùng kỳ trên trục tung Ma trận BCG |
| **Thang đo Likert 2** | **Phân nhóm tăng trưởng** *(Thang đo cho KPI `YoY Growth Pct`)* | `Growth Group` | `SWITCH(...)` | **Thang đo & Đường cắt Phân nhóm Tăng trưởng (Trục Y):**<br>- **Vùng**: Đường cắt Trung bình YoY = +13.44% (năm gần nhất) ➔ Tăng trưởng Nhanh vs Chậm<br>- **Tỉnh**: Thang 4 mức Tứ phân vị (Q1=7.66%, Q2=13.13%, Q3=18.65%) ➔ Đường cắt Trung vị Q2 = 13.13%<br>- **Huyện**: Thang 4 mức Tứ phân vị (Q1=-3.12%, Q2=-0.23%, Q3=+2.95%) ➔ Đường cắt Trung vị Q2 = -0.23% |
| **KPI Định vị BCG** | **Chiến lược đề xuất Ma trận BCG** *(Kết hợp `Revenue Tier Group` & `Growth Group`)* | `Recommend Strategy` | Kết hợp 2 chiều Trục X & Trục Y | **Phân 4 góc phần tư Ma trận BCG:**<br>- ⭐ **Ngôi sao**: Doanh thu Cao & Tăng trưởng Nhanh (Ưu tiên đầu tư mở rộng)<br>- 🐮 **Bò sữa**: Doanh thu Cao & Tăng trưởng Chậm (Duy trì thị phần & Tối ưu hiệu quả)<br>- ❓ **Dấu hỏi**: Doanh thu Thấp & Tăng trưởng Nhanh (Ưu tiên đầu tư có chọn lọc)<br>- 🐕 **Chó mực**: Doanh thu Thấp & Tăng trưởng Chậm (Tái phân bổ nguồn lực) |

### 🎯 Nguyên lý Phân 4 Nhóm của Ma trận BCG (Bóc tách Doanh thu vs Tăng trưởng)
Ma trận BCG phân chia toàn bộ địa bàn thành **4 góc phần tư** dựa trên sự giao thoa của 2 trục độc lập: **Trục X (Doanh thu / Thị phần)** và **Trục Y (Tốc độ tăng trưởng YoY)** thông qua các đường cắt chuẩn mực (Benchmark). Việc phân 4 nhóm này giúp doanh nghiệp bóc tách rõ nét 4 trạng thái thị trường:
1. **Khu vực có Doanh thu Cao nhưng Tốc độ tăng trưởng Thấp (🐮 Bò sữa - Cash Cow):**
   * **Bản chất**: Thị trường đã phát triển chín muồi, quy mô dòng tiền cực kỳ dồi dào và ổn định nhưng dung lượng đã đạt ngưỡng bão hòa, tốc độ tăng trưởng chững lại.
   * **Ý nghĩa & Hành động**: Không cần tiếp tục đổ thêm vốn lớn để mở rộng mạng lưới; tập trung tối ưu hóa chi phí vận hành, thu hoạch tối đa lợi nhuận biên để tạo ra dòng tiền thặng dư tái đầu tư nuôi các thị trường tiềm năng.
2. **Khu vực có Doanh thu Thấp nhưng Tốc độ tăng trưởng Nhanh (❓ Dấu hỏi - Question Mark):**
   * **Bản chất**: Thị trường mới nổi, hiện tại quy mô doanh thu còn khiêm tốn nhưng sức mua đang bùng nổ mạnh mẽ, là động cơ tăng trưởng trong tương lai.
   * **Ý nghĩa & Hành động**: Đầu tư có chọn lọc; nghiên cứu sâu hành vi tiêu dùng và ngành hàng dẫn dắt để rót vốn tiếp thị đúng trọng tâm, thúc đẩy gia tăng thị phần để chuyển hóa thành Ngôi sao.
3. **Khu vực có Doanh thu Cao và Tốc độ tăng trưởng Nhanh (⭐ Ngôi sao - Star):**
   * **Bản chất**: Thị trường động lực vàng, vừa nắm giữ quy mô doanh thu áp đảo vừa liên tục bành trướng mạnh mẽ.
   * **Ý nghĩa & Hành động**: Ưu tiên cao nhất mọi nguồn lực đầu tư (marketing, nhân sự, logistics, kho vận) nhằm bảo vệ vị thế quán quân và chiếm lĩnh tối đa thị phần.
4. **Khu vực có Doanh thu Thấp và Tốc độ tăng trưởng Chậm/Thấp (🐕 Chó mực - Dog):**
   * **Bản chất**: Thị trường kém hiệu quả, vừa chiếm tỷ trọng nhỏ vừa tăng trưởng ì ạch hoặc suy thoái.
   * **Ý nghĩa & Hành động**: Tinh gọn bộ máy, cắt giảm ngân sách xúc tiến, rà soát mô hình phân phối hoặc chuyển đổi mô hình (ví dụ chuyển giao văn phòng chi phí cao sang đại lý ủy quyền).

### 🎯 Thang đo & Đường cắt Phân nhóm Ma trận BCG theo Cấp Địa Giới

#### 1. Cấp Vùng (Region): Đường cắt theo Trung bình cộng (Mean Benchmark)
* **Đường cắt Doanh thu**: Trung bình cộng = $33.33\%$ tổng doanh thu toàn quốc (~4.29 tỷ ₫ khi xem toàn kỳ).
* **Đường cắt Tăng trưởng**: Trung bình cộng YoY của 3 vùng ($-2.65\%$ toàn kỳ, $+13.44\%$ năm gần nhất).
* **Định vị 3 Vùng trên BCG:**
  * **Miền Đông (East)**: Doanh thu Cao ($46.52\%$) & Tăng trưởng Chậm ➔ 🐮 **Bò sữa (Cash Cow)**.
  * **Miền Trung (Central)**: Doanh thu Thấp ($30.07\%$) & Tăng trưởng Nhanh ➔ ❓ **Dấu hỏi (Question Mark)**.
  * **Miền Tây (West)**: Doanh thu Thấp ($23.42\%$) & Tăng trưởng Chậm ➔ 🐕 **Chó mực (Dog)**.

#### 2. Cấp Thành phố (42 City): Thang đo 4 mức & Đường cắt Trung vị (Median $Q2$)
* **Thang đo Likert Doanh thu tỉnh (4 mức Tứ phân vị):**
  * `Q1 = 197.5M (1.53%)`, `Q2 = 319.1M (2.48%)`, `Q3 = 417.4M (3.24%)`
  * ➔ **Đường cắt Doanh thu tỉnh BCG = Trung vị Q2 = 319.1 Triệu ₫ (2.48%)** (Doanh thu Cao $\ge 319.1\text{M}$ vs Thấp $< 319.1\text{M}$).
* **Thang đo Likert Tăng trưởng YoY tỉnh (4 mức Tứ phân vị):**
  * `Q1 = 7.66%`, `Q2 = 13.13%`, `Q3 = 18.65%`
  * ➔ **Đường cắt Tăng trưởng tỉnh BCG = Trung vị Q2 = 13.13%** (Tăng trưởng Nhanh $\ge 13.13\%$ vs Chậm $< 13.13\%$).
* **Phân bổ 42 Tỉnh vào 4 góc Ma trận BCG:**
  * ⭐ **Ngôi sao (11 tỉnh)**: Doanh thu $\ge 319.1\text{M}$ & YoY $\ge 13.13\%$ *(Hà Nội, Sơn Tây, Nam Định, Thái Nguyên, Phủ Lý...)*.
  * 🐮 **Bò sữa (10 tỉnh)**: Doanh thu $\ge 319.1\text{M}$ & YoY $< 13.13\%$ *(Hải Phòng, Hạ Long, Ninh Bình, Bắc Giang...)*.
  * ❓ **Dấu hỏi (10 tỉnh)**: Doanh thu $< 319.1\text{M}$ & YoY $\ge 13.13\%$ *(Kon Tum, Pleiku, Buôn Ma Thuột, Rạch Giá...)*.
  * 🐕 **Chó mực (11 tỉnh)**: Doanh thu $< 319.1\text{M}$ & YoY $< 13.13\%$ *(Cần Thơ, Bến Tre, Vĩnh Long, Mỹ Tho...)*.

#### 3. Cấp Quận/Huyện (534 District): Thang đo 4 mức & Đường cắt Trung vị (Median $Q2$)
* **Thang đo Likert Doanh thu huyện (4 mức Tứ phân vị):**
  * `Q1 = 18.1 Triệu ₫ (0.141%)`, `Q2 = 22.9 Triệu ₫ (0.178%)`, `Q3 = 29.2 Triệu ₫ (0.228%)`
  * ➔ **Đường cắt Doanh thu huyện BCG = Trung vị Q2 = 22.9 Triệu ₫** (Doanh thu Cao $\ge 22.9\text{M}$ vs Thấp $< 22.9\text{M}$).
* **Thang đo Likert Tăng trưởng YoY huyện (4 mức Tứ phân vị):**
  * `Q1 = -3.12%`, `Q2 = -0.23%`, `Q3 = +2.95%`
  * ➔ **Đường cắt Tăng trưởng huyện BCG = Trung vị Q2 = -0.23%** (Tăng trưởng Nhanh $\ge -0.23\%$ vs Chậm $< -0.23\%$).
* **Phân bổ 534 Huyện vào 4 góc Ma trận BCG:**
  * ⭐ **Ngôi sao (111 huyện)**: Doanh thu $\ge 22.9\text{M}$ & YoY $\ge -0.23\%$ *(Quận Cầu Giấy, Hoàn Kiếm, Đống Đa, TP. Nam Định, TP. Sơn Tây...)*.
  * 🐮 **Bò sữa (156 huyện)**: Doanh thu $\ge 22.9\text{M}$ & YoY $< -0.23\%$ *(Các huyện thị lớn lâu đời tại Miền Đông, Hải Phòng, Bắc Ninh...)*.
  * ❓ **Dấu hỏi (156 huyện)**: Doanh thu $< 22.9\text{M}$ & YoY $\ge -0.23\%$ *(Các huyện đang bứt phá tại Tây Nguyên, Duyên hải Nam Trung Bộ...)*.
  * 🐕 **Chó mực (111 huyện)**: Doanh thu $< 22.9\text{M}$ & YoY $< -0.23\%$ *(Các huyện vùng sâu, hải đảo tại Miền Tây, Đồng bằng Sông Cửu Long...)*.

### 📌 Bảng Đề xuất Chiến lược Phân bổ Nguồn lực theo Ma trận BCG
| Góc Ma trận BCG | Đặc điểm nhận diện | Đề xuất Chiến lược Phân bổ Nguồn lực |
| :--- | :--- | :--- |
| ⭐ **Ngôi sao (Star)** | Doanh thu Cao & Tăng trưởng Nhanh | **Ưu tiên đầu tư mở rộng**: Bơm thêm ngân sách marketing, tăng nhân sự và mở thêm kho bãi để chiếm lĩnh tối đa thị phần. |
| 🐮 **Bò sữa (Cash Cow)** | Doanh thu Cao & Tăng trưởng Chậm | **Duy trì & Tối ưu hóa chi phí**: Thu lợi nhuận tối đa, không đổ thêm vốn lớn, dùng dòng tiền thặng dư nuôi các thị trường tiềm năng. |
| ❓ **Dấu hỏi (Question Mark)**| Doanh thu Thấp & Tăng trưởng Nhanh | **Đầu tư có chọn lọc**: Nghiên cứu lý do tăng trưởng vọt, rót vốn tập trung vào các mặt hàng bán chạy để chuyển hóa thành Ngôi sao. |
| 🐕 **Chó mực (Dog)** | Doanh thu Thấp & Tăng trưởng Chậm | **Tái phân bổ nguồn lực**: Cắt giảm chi phí vận hành, rà soát mô hình phân phối, xem xét sáp nhập hoặc chuyển giao cho đại lý. |

---

## 5. Problem Statement 5: Đánh giá Hiệu quả Mạng lưới Văn phòng & Đại lý
* **Mục tiêu**: Đánh giá và xếp hạng hiệu quả kinh doanh của 98 đơn vị kinh doanh (42 Văn phòng + 56 Đại lý) nhằm **tối ưu hóa mạng lưới phân phối**.

### 📐 Danh mục Measure - Metric - KPI
| Cấp độ | Tên chỉ số | Ký hiệu / DAX | Công thức | Thang đo Likert & Đánh giá |
| :--- | :--- | :--- | :--- | :--- |
| **Base Measure** | Doanh thu thuần đơn vị | `Unit Net Revenue` | `CALCULATE([Net Revenue], NOT(ISBLANK(dim_geography[unit_key])))` | Quy mô dòng tiền thuần thực tế phát sinh tại đơn vị |
| **Base Measure** | Số hóa đơn xử lý | `Unit Invoice Count` | `CALCULATE(DISTINCTCOUNT(order_id), NOT(ISBLANK(unit_key)))` | Quy mô giao dịch/hóa đơn đơn vị phục vụ |
| **Base Measure** | Khách hàng phục vụ | `Unit Served Customers`| `CALCULATE(DISTINCTCOUNT(customer_key), NOT(ISBLANK(unit_key)))` | Quy mô tệp khách hàng thực tế tiếp cận được |
| **Metric (ARPU)** | Doanh thu bình quân / Khách | `Revenue Per Customer` | `DIVIDE([Unit Net Revenue], [Unit Served Customers], 0)` | Mức chi tiêu trung bình của 1 khách hàng tại đơn vị |
| **Metric (AOV)** | Doanh thu bình quân / Đơn | `Revenue Per Invoice` | `DIVIDE([Unit Net Revenue], [Unit Invoice Count], 0)` | Quy mô giá trị trung bình 1 đơn hàng xử lý tại đơn vị |
| **Metric** | Xếp hạng đơn vị | `Overall Rank` | `SELECTEDVALUE(dim_business_unit[overall_rank])` | Thứ hạng nội bộ xếp hạng dựa trên `KPI Score` (VP #1-42, Đại lý #1-56) |
| **KPI Cốt Lõi** | **Điểm hiệu quả tổng hợp** | `KPI Score` | `(Percentile(ARPU) + Percentile(AOV)) / 2 * 100` | Điểm số năng lực chuẩn hóa (thang 0 - 100) tính trên 2 trụ cột giá trị khách & giá trị đơn |
| **Thang đo Likert** | **Phân nhóm hiệu suất** *(Thang đo cho KPI `KPI Score`)* | `Unit Performance Group` | Phân cấp theo Tứ phân vị chuẩn xác của KPI Score (Q1=37.76, Q2=48.98, Q3=64.54) | **Thang 4 mức Tứ phân vị chuẩn xác:**<br>- `>= 64.54 điểm (>= Q3)`: **4. Xuất sắc** (25 đơn vị)<br>- `48.98 - 64.54 điểm (Q2 - Q3)`: **3. Tốt** (24 đơn vị)<br>- `37.76 - 48.98 điểm (Q1 - Q2)`: **2. Trung bình** (25 đơn vị)<br>- `< 37.76 điểm (< Q1)`: **1. Thấp** (24 đơn vị) |
| **Đề xuất Chiến lược** | **Gợi ý tối ưu mạng lưới** *(Dựa trên `Unit Performance Group`)* | `Recommendation` | `SELECTEDVALUE(dim_business_unit[recommendation])` | **Đề xuất hành động theo từng nhóm hiệu suất:**<br>- **Xuất sắc**: Ưu tiên mở rộng & Nhân rộng mô hình chuẩn mẫu (Benchmark)<br>- **Tốt**: Duy trì & Tối ưu chi phí vận hành<br>- **Trung bình**: Đào tạo nhân sự, thúc đẩy bán chéo & Tăng AOV<br>- **Thấp**: Rà soát chi phí cố định; chuyển đổi sang Đại lý ủy quyền tinh gọn |

### 📐 Công thức KPI Tổng hợp (Composite KPI Score trên 2 Trụ cột)
Tích hợp 2 chỉ số năng lực giá trị cốt lõi về cùng **thang điểm 0 - 100** bằng phương pháp chuẩn hóa phân vị (Percentile):
$$\text{KPI Score} = \frac{\text{Percentile}(\text{Revenue Per Customer}) + \text{Percentile}(\text{Revenue Per Invoice})}{2} \times 100$$

*Trong đó:*
- `Revenue Per Customer` = `Doanh thu thuần / Khách phục vụ` (ARPU đơn vị - đo lường mức chi tiêu bình quân của khách hàng).
- `Revenue Per Invoice` = `Doanh thu thuần / Số hóa đơn` (AOV đơn vị - đo lường quy mô giá trị trung bình một giao dịch).

### 🏆 Xếp hạng & Thang đo Likert 4 mức (Tính trên 98 đơn vị)
- **Xếp hạng (`Overall Rank`)**: Xếp hạng dựa trực tiếp trên `KPI Score`, phân nhóm riêng biệt Văn phòng (#1 ➔ #42) và Đại lý (#1 ➔ #56); hỗ trợ lọc theo Slicer Region/City để **so sánh các đơn vị trong cùng 1 địa bàn**.

| Thang đo Likert 4 mức | Ngưỡng Tứ phân vị KPI Score | Số lượng đơn vị | Đánh giá năng lực |
| :--- | :--- | :--- | :--- |
| **Mức 1 - Thấp** | $< 37.76\text{ điểm } (< Q1)$ | 24 đơn vị | Hiệu quả thấp, cần rà soát chi phí / tái cơ cấu |
| **Mức 2 - Trung bình** | $37.76 - 48.98\text{ điểm } (Q1 - Q2)$ | 25 đơn vị | Vận hành mức trung bình, cần tăng giá trị đơn |
| **Mức 3 - Tốt** | $48.98 - 64.54\text{ điểm } (Q2 - Q3)$ | 24 đơn vị | Vận hành hiệu quả, khai thác tốt, duy trì ổn định |
| **Mức 4 - Xuất sắc** | $\ge 64.54\text{ điểm } (\ge Q3)$ | 25 đơn vị | **Đơn vị kiểu mẫu (Best Performer)** |

### 📌 Đề xuất Chiến lược Tối ưu Mạng lưới (Dựa trên Phân nhóm Hiệu suất & Mô hình Đơn vị)
1. **Nhóm Xuất sắc (25 đơn vị - KPI Score $\ge 64.54$):** Khen thưởng Ban điều hành; lấy quy trình tiếp cận khách hàng và bán hàng làm chuẩn mẫu (**Benchmark**) nhân rộng toàn quốc.
2. **Nhóm Tốt (24 đơn vị - KPI Score $48.98 - 64.54$):** Duy trì sự ổn định; tiếp tục tối ưu hóa quy trình vận hành và kiểm soát chặt chẽ chi phí để nâng cao tỷ suất lợi nhuận biên.
3. **Nhóm Trung bình (25 đơn vị - KPI Score $37.76 - 48.98$):** Đào tạo kỹ năng tư vấn cho nhân sự; triển khai các chương trình kích cầu, bán combo và up-sell nhằm đẩy mạnh giá trị đơn hàng (AOV) và mức chi tiêu của khách (ARPU).
4. **Nhóm Thấp (24 đơn vị - KPI Score $< 37.76$):** 
   - Đối với **Văn phòng**: Rà soát gánh nặng chi phí cố định (mặt bằng, nhân sự hành chính); nếu hiệu quả khai thác không tương xứng với chi phí, thực hiện chuyển đổi mô hình từ **Văn phòng chi phí cao sang Đại lý ủy quyền tinh gọn**.
   - Đối với **Đại lý**: Đánh giá lại năng lực đối tác, cắt giảm chính sách hỗ trợ kém hiệu quả hoặc tái cấu trúc phân bổ lại địa bàn quản lý.

---

## 📊 Bảng Đối Chiếu Trực Quan Hóa (Dashboard Mapping)

| Problem Statement | Nhóm Visual Triển Khai Thực Tế | Chiều Phân Tích (Dimensions) | Chỉ Số Thể Hiện Đồng Bộ Trong SSAS | Thư Mục SSAS (Display Folder) |
| :---: | :--- | :--- | :--- | :--- |
| **PS1** | 3 Card KPI + Bar Chart + Waterfall + Matrix Phân Cấp | Region, City, District | `Gross Revenue`, `Refund Amount`, `Net Revenue`, `Refund Value Pct`, `Revenue Share Pct KPI`, `Revenue Group`, `Waterfall Value` | `PS1 - Doanh thu & Địa bàn` |
| **PS2** | 3 Card KPI + Clustered Column Chart + Bar Chart Gap | Region, City, District | `Purchased Qty`, `Returned Qty`, `Net Quantity`, `Quantity Share Pct KPI`, `Return Qty Rate Pct`, `Quantity Gap Abs`, `Quantity Gap Pct`, `Quantity Disparity Index`, `Quantity Group` | `PS2 - Sản lượng & Phân phối` |
| **PS3** | 3 Card KPI + Multi-line Chart + Scatter Plot + Decomposition Tree | Region, City, District, Date | `Order Count`, `Customer Count`, `Returned Order Count`, `Returned Order Pct`, `AOV`, `ARPU`, `Orders Per Customer`, `AOV Group`, `ARPU Group`, `Orders Per Customer Group` | `PS3 - Khách hàng & AOV` |
| **PS4** | Scatter Chart Ma trận BCG + Stacked Bar + Table Rank | Region, City, District, Year | `Net Revenue`, `Revenue Share Pct KPI`, `YoY Growth Pct`, `Revenue Rank`, `Revenue Tier Group`, `Growth Group`, `Recommend Strategy` | `PS4 - Tăng trưởng & Ma trận` |
| **PS5** | 3 Card KPI + Scatter KPI Score vs Rank + Table Rank | Business Unit, Unit Type, City | `Unit Net Revenue`, `Unit Invoice Count`, `Unit Served Customers`, `Revenue Per Customer`, `Revenue Per Invoice`, `KPI Score`, `Overall Rank`, `Unit Performance Group`, `Recommendation` | `PS5 - Văn phòng & Đại lý` |
| **Tooltip / Filter** | 5 Trang Tooltip Động (PS2, PS3, PS4, PS4_2, PS5) | Dynamic Filter Hierarchy | `Selected Geography` (Tiêu đề địa bàn động cho Card Tooltip) | `Hỗ trợ Bộ lọc` |
