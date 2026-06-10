# E-Commerce Performance Dashboard - Layout & Wireframe Design

This design document outlines a highly premium, modern, and readable Power BI dashboard design. It is structured into four functional pages, enabling stakeholders—from executive leadership to operations managers—to extract business insights quickly.

---

## Centralized Design Guidelines

To guarantee a client-ready, professional layout, all pages follow these styling rules:
1. **Typography**: Use **Inter** or **Outfit** as the primary dashboard font (Google Fonts standard). 
2. **Color Palette**: Modern **Glassmorphism / Slate** color scheme:
   * **Background**: Very dark grey/slate (dark mode: `#0D0E12`) or clean light grey/white (`#F8F9FD`).
   * **Primary Metric Color**: Crisp Cobalt/Indigo (`#3B82F6` for revenue metrics).
   * **Secondary Success Color**: Vibrant Emerald (`#10B981` for profit/growth).
   * **Warning/Alert Color**: Coral Red (`#EF4444` for returns/refunds).
3. **Visual Hierarchy**: Consistent structural partitions with rounded corners (8px border radius) and subtle borders or card shadows. Section headings are always clearly visible.
4. **Header Banner**: Every page features a standardized top header banner containing the **Page Title**, **Current Filter Context Summary**, and **Global Navigation Tabs**.
5. **Universal Filter Panel**: A unified filter dock is placed consistently (either a collapsible left sidebar or a top horizontal strip) to house slicers for:
   * **Date Range** (Between slicer)
   * **Sales Channel** (Multi-select dropdown)
   * **Product Category** (Multi-select dropdown)
   * **Customer Region** (Dropdown list)

---

## Page 1: Executive Overview
![Executive Overview Mockup](/C:/Users/Sam/.gemini/antigravity/brain/acbf6c4a-1177-49a6-98a5-c4f173456e39/dashboard_overview_mockup_1779269828888.png)

### Page Objective
Provide a clean high-level summary of the brand's financial health, multi-channel performance, and top-line velocity.

### Wireframe Layout Structure
* **Top Strip (Header & Slicers)**: Page title and collapsed filter dock.
* **First Block (Row 1 - KPI Cards)**: Horizontal strip of 4 massive KPI cards with dynamic sparklines.
* **Second Block (Row 2 - Left: 60% Width, Right: 40% Width)**: 
  * *Left*: Main financial trend chart.
  * *Right*: Channel performance matrix.
* **Third Block (Row 3 - Left: 40% Width, Right: 60% Width)**:
  * *Left*: Cumulative category shares.
  * *Right*: High-level order fulfillment volume breakdown.

### KPI Cards (Calculated Measures)
1. **Net Revenue Card**: Displays `[Net Revenue]` with a MoM percentage indicator (`[MoM Revenue Growth %]`).
2. **Total Orders Card**: Displays `[Total Orders]`.
3. **Gross Profit Card**: Displays `[Total Profit]`.
4. **Profit Margin % Card**: Displays `[Profit Margin %]` with color conditional formatting (Green if >= 30%, Amber if 20-29%, Red if < 20%).

### Recommended Visuals
* **Line & Stacked Column Chart**: *Net Revenue* and *Total Profit* (Columns) and *Profit Margin %* (Line) plotted over *Calendar Month*.
  * *Why included*: Visually shows revenue vs profit trends over time, helping executives spot seasonal peak performance.
* **Horizontal Bar Chart**: *Net Revenue* and *Total Profit* by *Channel Name*.
  * *Why included*: Instantly shows which sales platforms (Shopify vs. Amazon) are driving volume vs. margin.
* **Donut Chart**: *Net Revenue* by *Product Category*.
  * *Why included*: Provides a quick glance at the category mix.

### Interactive Features
* **Drill-down**: Time trend chart allows drilling down from *Year* -> *Quarter* -> *Month* -> *Day*.
* **Custom Tooltip**: Hovering over a channel bar reveals: *Total Orders*, *AOV*, *Return Rate %*, and *Platform Fees*.
* **Business Questions Answered**: 
  * "What is our overall sales run-rate and are we growing MoM?"
  * "Which channels are driving the highest profitability?"

---

## Page 2: Product Performance

### Page Objective
Analyze catalog velocity, margins, and cost structures to isolate top-selling hero items from inventory leakage.

### Wireframe Layout Structure
* **First Block (Row 1 - KPI Cards)**:
  * Top-performing Category (by net revenue).
  * Best Seller SKU.
  * Average Discount applied to products.
* **Second Block (Row 2 - Left: 50% Width, Right: 50% Width)**:
  * *Left*: Profitability scatter plot.
  * *Right*: Category tree map.
* **Third Block (Row 3 - 100% Width)**:
  * Product performance details grid with conditional formatting.

### KPI Cards (Calculated Measures)
1. **Hero Category**: `Top Category` based on `[Net Revenue]`.
2. **Best Seller**: Name and SKU of the product with the highest `[Total Orders]`.
3. **Average Discount %**: Weighted metric showing `[Average Discount %]`.

### Recommended Visuals
* **Scatter Plot**: *Total Orders* (X-axis) vs. *Profit Margin %* (Y-axis) with bubbles representing individual *Product Names* colored by *Category*.
  * *Why included*: Immediately isolates high-volume low-profit items (bottom-right quadrant) and high-margin low-volume products (top-left quadrant) to optimize product pricing.
* **Treemap**: *Net Revenue* and *Total Profit* by *Product Category*.
  * *Why included*: Visualizes relative contribution shares across categories.
* **BI Detail Table**: Rows of *SKU*, *Product Name*, *Category*, *Wholesale Cost*, *Retail Price*, *Units Sold*, *Net Revenue*, *Total Profit*, *Profit Margin %*, and *Return Rate %*.
  * *Why included*: Provides an exhaustive operational view, allowing product managers to sort by margin or return rate.

### Interactive Features
* **Drill-down**: Double-clicking a category in the Treemap drills down to show details of individual products in that category.
* **Custom Tooltip**: Hovering over a product bubble in the scatter plot shows its *SKU*, *Wholesale Cost*, *Retail Price*, and *Return Rate %*.
* **Business Questions Answered**:
  * "Which products have high volume but low profitability?"
  * "Are specific categories suffering from margin erosion due to high costs?"

---

## Page 3: Customer & Region Analysis

### Page Objective
Evaluate customer lifetime value (LTV), geographic order density, acquisition velocity, and repeat cohort behaviors.

### Wireframe Layout Structure
* **First Block (Row 1 - KPI Cards)**:
  * Total unique active customers.
  * Brand repeat customer rate.
  * Top-grossing state.
* **Second Block (Row 2 - Left: 55% Width, Right: 45% Width)**:
  * *Left*: Geographic bubble map.
  * *Right*: Customer cohort stack chart.
* **Third Block (Row 3 - 100% Width)**:
  * High-value LTV customer leaderboard table.

### KPI Cards (Calculated Measures)
1. **Total Customers**: Displays `[Total Customers]`.
2. **Repeat Customer Rate %**: Displays `[Repeat Customer Rate %]` (Target: > 35%).
3. **Top State**: Displays the US State with the highest `[Net Revenue]`.

### Recommended Visuals
* **US Map (Bubble or Choropleth)**: States colored by *Net Revenue*, with bubble size indicating *Total Orders*.
  * *Why included*: Instantly displays regional sales density to guide geographically targeted marketing spend.
* **Stacked Column Chart**: *Net Revenue* split by *Customer Type* (New vs. Repeat) over *Calendar Quarter*.
  * *Why included*: Highlights customer cohort dynamics, showing whether growth is fueled by new acquisitions or steady repeat purchasers.
* **Leaderboard Table**: Rows representing top customers by spend: *Customer Name*, *City*, *State*, *Signup Date*, *Total Orders*, *Net Revenue*, *LTV*, and *Average Order Value*.
  * *Why included*: Enables sales reps to target VIP customers for reward campaigns.

### Interactive Features
* **Cross-filtering**: Selecting a state on the map filters the customer table and cohort stack chart for that specific state.
* **Custom Tooltip**: Hovering over a state shows: *Top Category*, *AOV*, *Repeat Rate %*, and *Return Rate %*.
* **Business Questions Answered**:
  * "What regions have the highest sales density and average spend?"
  * "Is our repeat cohort growing quarter-over-quarter?"

---

## Page 4: Discount & Returns Analysis

### Page Objective
Identify margin leakage. Audit the impact of discount bands on profitability and investigate return reason distributions.

### Wireframe Layout Structure
* **First Block (Row 1 - KPI Cards)**:
  * Total Refunded Cash.
  * Return Rate % (against target).
  * Discount Revenue Share (net sales on promo).
* **Second Block (Row 2 - Left: 50% Width, Right: 50% Width)**:
  * *Left*: Discount bands margins chart.
  * *Right*: Return reasons distribution.
* **Third Block (Row 3 - 100% Width)**:
  * Margin Cannibalization Alert Table (using the High Discount Low Profit measure).

### KPI Cards (Calculated Measures)
1. **Refund Amount**: Displays `[Refund Amount]` (with dynamic Warning color formatting).
2. **Return Rate**: Displays `[Return Rate %]`.
3. **Discount Revenue**: Displays `[Revenue from Discounted Orders]`.

### Recommended Visuals
* **Line & Clustered Column Chart**: *Net Revenue* (Column) and *Profit Margin %* (Line) by *Discount Band* (`No Discount`, `1-10%`, `11-20%`, `21-30%`, `31%+`).
  * *Why included*: Clearly shows the impact of promotions. Ideally, margin lines should not plummet steeply in higher discount levels.
* **Donut Chart**: Count of *Return IDs* by *Return Reason*.
  * *Why included*: Shows why returns happen (e.g. *Wrong Size* vs. *Defective Item*), driving adjustments in sizing charts or quality control.
* **Clustered Bar Chart**: *Return Rate %* by *Product Category*.
  * *Why included*: Pinpoints which category (e.g. Apparel) is driving the return leakage.
* **Margin Alert Table**: Lists orders where `[High Discount Low Profit Flag] = 1`. Includes: *Order ID*, *Order Date*, *Product Name*, *Channel Name*, *Discount %*, *Net Revenue*, and *Profit Margin %*.
  * *Why included*: Directs operational attention to transactions causing margin leakage.

### Interactive Features
* **Cross-filtering**: Selecting the "Wrong Size" segment on the return reason chart automatically filters the categories to show which ones (like Apparel) are the culprits.
* **Tooltip**: Hovering over a category bar shows: *Total Returns*, *Total Net Revenue*, and *Refund Amount*.
* **Business Questions Answered**:
  * "Are our 30%+ discount campaigns cannibalizing margins?"
  * "What categories are leaking the most cash through refunds and why?"
