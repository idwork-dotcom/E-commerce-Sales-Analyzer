# E-Commerce Performance Dashboard - DAX Measures Portfolio
**Target BI Tool**: Power BI Desktop / Service  
**Date Table Dependency**: `dim_calendar`  
**Fact Table**: `fact_sales`

This document details the portfolio of 20 Power BI DAX measures designed to query and aggregate the e-commerce performance dataset. These measures leverage the star-schema relationships and are divided into:
* **Core Sales & Profitability**
* **Customer Retention & Behavior**
* **Time Intelligence (MoM)**
* **Promotion & Discounts Analytics**
* **Returns & Auditing**

---

## 1. Core Sales & Profitability KPIs

### [Measure 1] Total Revenue (Gross)
* **DAX Formula**:
  ```dax
  Total Revenue = SUM(fact_sales[gross_revenue])
  ```
* **Explanation**: The total base sales value generated before any discounts are applied. Cancelled orders are automatically excluded as their base revenue is pre-computed as `$0.00` in the DWH layer.
* **Formatting**: Currency (`$#,##0.00`)

### [Measure 2] Net Revenue
* **DAX Formula**:
  ```dax
  Net Revenue = SUM(fact_sales[net_revenue])
  ```
* **Explanation**: The actual top-line revenue collected by the business after processing product discounts:
  $$\text{Gross Revenue} - \text{Discount Amount}$$
* **Formatting**: Currency (`$#,##0.00`)

### [Measure 3] Total Profit
* **DAX Formula**:
  ```dax
  Total Profit = SUM(fact_sales[gross_profit])
  ```
* **Explanation**: The net gross margin earned by the retail brand after billing item cost of goods sold (COGS), shipping charges, and channel commission/platform fees.
* **Formatting**: Currency (`$#,##0.00`)

### [Measure 4] Profit Margin %
* **DAX Formula**:
  ```dax
  Profit Margin % = DIVIDE([Total Profit], [Net Revenue], 0)
  ```
* **Explanation**: The ratio of profit earned per dollar of net revenue. Using `DIVIDE` instead of the division operator `/` prevents standard divide-by-zero errors when no sales occurred.
* **Formatting**: Percentage (`0.0%`)

### [Measure 5] Average Order Value (AOV)
* **DAX Formula**:
  ```dax
  Average Order Value = DIVIDE([Net Revenue], [Total Orders], 0)
  ```
* **Explanation**: The average net revenue earned per invoice/order placed.
* **Formatting**: Currency (`$#,##0.00`)

---

## 2. Order Volume & Returns KPIs

### [Measure 6] Total Orders
* **DAX Formula**:
  ```dax
  Total Orders = DISTINCTCOUNT(fact_sales[order_id])
  ```
* **Explanation**: The absolute count of transactions processed.
* **Formatting**: Decimal Number (`#,##0`)

### [Measure 7] Completed Orders
* **DAX Formula**:
  ```dax
  Completed Orders = 
  CALCULATE(
      [Total Orders],
      fact_sales[order_status] = "Completed"
  )
  ```
* **Explanation**: The count of orders that were successfully shipped, settled, and not returned or cancelled.
* **Formatting**: Decimal Number (`#,##0`)

### [Measure 8] Returned Orders
* **DAX Formula**:
  ```dax
  Returned Orders = 
  CALCULATE(
      [Total Orders],
      fact_sales[is_returned] = 1
  )
  ```
* **Explanation**: The count of completed orders that were subsequently returned by the customer.
* **Formatting**: Decimal Number (`#,##0`)

### [Measure 9] Return Rate %
* **DAX Formula**:
  ```dax
  Return Rate % = 
  DIVIDE(
      [Returned Orders],
      CALCULATE(
          [Total Orders],
          fact_sales[order_status] <> "Cancelled"
      ),
      0
  )
  ```
* **Explanation**: The percentage of settled orders (Completed + Returned + Refunded) that resulted in returns. Excludes Cancelled orders from the denominator.
* **Formatting**: Percentage (`0.00%`)

### [Measure 10] Refund Amount
* **DAX Formula**:
  ```dax
  Refund Amount = SUM(fact_sales[return_amount])
  ```
* **Explanation**: The total cash value refunded to customers for returned goods (excluding shipping).
* **Formatting**: Currency (`$#,##0.00`)

---

## 3. Customer Retention & Cohort KPIs

### [Measure 11] Total Customers
* **DAX Formula**:
  ```dax
  Total Customers = DISTINCTCOUNT(fact_sales[customer_id])
  ```
* **Explanation**: The unique count of active purchasing customers within the filtered filter context.
* **Formatting**: Decimal Number (`#,##0`)

### [Measure 12] Repeat Customers (Data Warehouse Assisted)
* **DAX Formula**:
  ```dax
  Repeat Customers = 
  CALCULATE(
      DISTINCTCOUNT(fact_sales[customer_id]),
      fact_sales[customer_type] = "Repeat"
  )
  ```
* **Explanation**: The count of unique customers who have made their 2nd or subsequent order. Highly optimized as it utilizes the pre-computed `customer_type` index from `fact_sales`.
* **Formatting**: Decimal Number (`#,##0`)

### [Measure 13] Repeat Customers (Dynamic Pure DAX Alternative)
* **DAX Formula**:
  ```dax
  Repeat Customers (Dynamic) = 
  COUNTROWS(
      FILTER(
          VALUES(fact_sales[customer_id]),
          CALCULATE(DISTINCTCOUNT(fact_sales[order_id])) > 1
      )
  )
  ```
* **Explanation**: Computes repeat customers dynamically in the visual. Useful if you want to analyze repeat behavior strictly inside a filtered time segment, rather than over the brand's full history.
* **Formatting**: Decimal Number (`#,##0`)

### [Measure 14] Repeat Customer Rate %
* **DAX Formula**:
  ```dax
  Repeat Customer Rate % = DIVIDE([Repeat Customers], [Total Customers], 0)
  ```
* **Explanation**: The percentage of your customer base that are repeat buyers. An essential metric for Customer Retention cost auditing.
* **Formatting**: Percentage (`0.0%`)

---

## 4. Time Intelligence & Growth KPIs

### [Measure 15] Month-over-Month Revenue Growth %
* **DAX Formula**:
  ```dax
  MoM Revenue Growth % = 
  VAR CurrentRevenue = [Net Revenue]
  VAR PriorMonthRevenue = 
      CALCULATE(
          [Net Revenue],
          DATEADD(dim_calendar[date], -1, MONTH)
      )
  RETURN
      DIVIDE(CurrentRevenue - PriorMonthRevenue, PriorMonthRevenue, 0)
  ```
* **Explanation**: Measures top-line sales velocity by comparing the current month's net revenue to the prior calendar month.
* **Formatting**: Percentage (`0.0%`)

### [Measure 16] Month-over-Month Profit Growth %
* **DAX Formula**:
  ```dax
  MoM Profit Growth % = 
  VAR CurrentProfit = [Total Profit]
  VAR PriorMonthProfit = 
      CALCULATE(
          [Total Profit],
          DATEADD(dim_calendar[date], -1, MONTH)
      )
  RETURN
      DIVIDE(CurrentProfit - PriorMonthProfit, PriorMonthProfit, 0)
  ```
* **Explanation**: Compares gross profit margins month-over-month to audit earnings health.
* **Formatting**: Percentage (`0.0%`)

---

## 5. Promotion & Discount Analytics

### [Measure 17] Discount Amount
* **DAX Formula**:
  ```dax
  Discount Amount = SUM(fact_sales[discount_amount])
  ```
* **Explanation**: The total dollar amount given away in promotional discounts.
* **Formatting**: Currency (`$#,##0.00`)

### [Measure 18] Average Discount %
* **DAX Formula**:
  ```dax
  Average Discount % = DIVIDE([Discount Amount], [Total Revenue], 0)
  ```
* **Explanation**: The weighted average discount rate across all orders (Gross Discount Share). More accurate than simple `AVERAGE(discount_pct)` as it is weighted by order size.
* **Formatting**: Percentage (`0.00%`)

### [Measure 19] Revenue from Discounted Orders
* **DAX Formula**:
  ```dax
  Revenue from Discounted Orders = 
  CALCULATE(
      [Net Revenue],
      fact_sales[discount_pct] > 0
  )
  ```
* **Explanation**: Total net revenue derived strictly from orders that had a promotion applied.
* **Formatting**: Currency (`$#,##0.00`)

### [Measure 20] Profit from Discounted Orders
* **DAX Formula**:
  ```dax
  Profit from Discounted Orders = 
  CALCULATE(
      [Total Profit],
      fact_sales[discount_pct] > 0
  )
  ```
* **Explanation**: Cumulative profit earned on orders with active promotional discounts. Helps evaluate if high-discount promotions are cannibalizing margins.
* **Formatting**: Currency (`$#,##0.00`)

### [Measure 21] High Discount Low Profit Flag
* **DAX Formula**:
  ```dax
  High Discount Low Profit Flag = 
  IF(
      SELECTEDVALUE(fact_sales[discount_pct]) >= 0.20 && [Profit Margin %] < 0.10,
      1,
      0
  )
  ```
* **Explanation**: An order-level visual alert. Returns `1` if an order received a high discount (>= 20%) but yielded low profitability (Profit Margin < 10%). Excellent for detail rows or conditionally formatting background colors in alert tables.
* **Formatting**: Whole Number

---

## Technical Notes: Filter Context & Relationships

### 1. Active Relationships in the Star Schema
Ensure the following active relationships are established in the Power BI Model View:

```
[dim_calendar] (date)  1 -------> * [fact_sales] (order_date)
[dim_customer] (customer_id) 1 -> * [fact_sales] (customer_id)
[dim_product]  (product_id)  1 -> * [fact_sales] (product_id)
[dim_channel]  (channel_id)  1 -> * [fact_sales] (channel_id)
```

### 2. The Calendar Table Dependency
* **Time Intelligence Functions**: Standard time intelligence functions like `DATEADD` and `SAMEPERIODLASTYEAR` require a dedicated contiguous date table. The `dim_calendar` table satisfies this requirement.
* **Mark as Date Table**: You **must** right-click the `dim_calendar` table in Power BI and select **Mark as Date Table**, selecting the `date` column as the unique identifier.
* **Auto Date/Time**: Disable *Auto Date/Time for new files* in Power BI Options to improve performance and prevent hidden calendar tables from bloating the model.

### 3. Filter Propagation & Performance
* **Filter Direction**: Keep the cross-filter direction set to **Single** (from dimension to fact table, `1 -> *`). Avoid using Bidirectional filters (`Both`) unless strictly necessary, as they create performance degradation and circular dependency risks.
* **BLANK Dividends**: The `DIVIDE` function is used across all division measures. In case the denominator is `0` or `BLANK`, `DIVIDE` returns `BLANK` by default (or the custom parameter `0` if defined), keeping charts clean without `#DIV/0!` errors.
