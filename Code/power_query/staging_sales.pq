let
// --- Load Data ---
    Source = Csv.Document(Web.Contents("https://raw.githubusercontent.com/EimanDaoud/Data-Cleaning--Data-Modeling---DAX-Measures-in-Power-BI/refs/heads/main/Data/Raw%20Data/Sales%20Records.csv"),[Delimiter=",", Columns=17, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),

// --- Data Types ---
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"Order_Date", type date}, {"Quantity", Int64.Type}, {"Discount", type number}}),

// --- Clean & Trim Text Columns ---
    #"Cleaned Text" = Table.TransformColumns(#"Changed Type",{{"Order_ID", Text.Clean, type text}, {"Customer_Name", Text.Clean, type text}, {"Segment", Text.Clean, type text}, {"Region", Text.Clean, type text}, {"City", Text.Clean, type text}, {"Product_ID", Text.Clean, type text}, {"Product_Name", Text.Clean, type text}, {"Category", Text.Clean, type text}, {"Unit_Price", Text.Clean, type text}, {"Total_Sales", Text.Clean, type text}, {"Cost", Text.Clean, type text}, {"Profit", Text.Clean, type text}, {"Payment_Type", Text.Clean, type text}, {"Sales_Rep", Text.Clean, type text}}),
    #"Trimmed Text" = Table.TransformColumns(#"Cleaned Text",{{"Order_ID", Text.Trim, type text}, {"Customer_Name", Text.Trim, type text}, {"Segment", Text.Trim, type text}, {"Region", Text.Trim, type text}, {"City", Text.Trim, type text}, {"Product_ID", Text.Trim, type text}, {"Product_Name", Text.Trim, type text}, {"Category", Text.Trim, type text}, {"Unit_Price", Text.Trim, type text}, {"Total_Sales", Text.Trim, type text}, {"Cost", Text.Trim, type text}, {"Profit", Text.Trim, type text}, {"Payment_Type", Text.Trim, type text}, {"Sales_Rep", Text.Trim, type text}}),

// --- Proper Case---
    #"Capitalized Each Word" = Table.TransformColumns(#"Trimmed Text",{{"Customer_Name", Text.Proper, type text}, {"Segment", Text.Proper, type text}, {"Region", Text.Proper, type text}, {"City", Text.Proper, type text}, {"Category", Text.Proper, type text}, {"Payment_Type", Text.Proper, type text}, {"Sales_Rep", Text.Proper, type text}}),

// --- Standardize Categorical Values ---
    #"Region Standarized1" = Table.ReplaceValue(#"Capitalized Each Word","Redsea","Red Sea",Replacer.ReplaceText,{"Region"}),
    #"Region Standarized2" = Table.ReplaceValue(#"Region Standarized1","Kasala","Kassala",Replacer.ReplaceText,{"Region"}),
    #"Region Standarized3" = Table.ReplaceValue(#"Region Standarized2","Khartom","Khartoum",Replacer.ReplaceText,{"Region"}),
    #"Payment Standarized" = Table.ReplaceValue(#"Region Standarized3","Bankk","Bank",Replacer.ReplaceText,{"Payment_Type"}),
    
// --- City Standardization --- 
    #"City Standardized" = Table.AddColumn(#"Payment Standarized", "City_clean", each if List.Contains({"Kassala", "Kasala"}, [City]) then "Kassala"
else if List.Contains({"Port Sudan", "Portsudan"}, [City]) then "Port Sudan"
else if List.Contains({"Khartom", "Khartoum"}, [City]) then "Khartoum"
else "Omdurman"),

// --- Unit Price Cleaning---
    #"Removed SDG Price" = Table.ReplaceValue(#"City Standardized","SDG"," ",Replacer.ReplaceText,{"Unit_Price"}),
    #"Detect k Price" = Table.AddColumn(#"Removed SDG Price", "price k detector", each if Text.Contains([Unit_Price], "k", Comparer.OrdinalIgnoreCase) then 1000 else 1),
    #"Changed Type2" = Table.TransformColumnTypes(#"Detect k Price",{{"price k detector", Int64.Type}}),
    #"Extract Digits Price" = Table.AddColumn(#"Changed Type2", "price digits", each Text.Select([Unit_Price], {"0".."9", "."})),
    #"Changed Type3" = Table.TransformColumnTypes(#"Extract Digits Price",{{"price digits", type number}}),
    #"Unit Price Clean" = Table.AddColumn(#"Changed Type3", "Unit_Price_clean", each [price digits]*[price k detector]),


// --- Cost Cleaning---
    #"Removed SDG Cost" = Table.ReplaceValue(#"Unit Price Clean","SDG"," ",Replacer.ReplaceText,{"Cost"}),
    #"Detect k Cost" = Table.AddColumn(#"Removed SDG Cost", "cost k detector", each if Text.Contains([Cost], "k", Comparer.OrdinalIgnoreCase) then 1000 else 1),
    #"Changed Type5" = Table.TransformColumnTypes(#"Detect k Cost",{{"cost k detector", Int64.Type}}),
    #"Extract Digits Cost" = Table.AddColumn(#"Changed Type5", "cost digits", each Text.Select([Cost], {"0".."9", ".","-"})),
    #"Changed Type6" = Table.TransformColumnTypes(#"Extract Digits Cost",{{"cost digits", type number}}),
    #"Cost Clean" = Table.AddColumn(#"Changed Type6", "Cost_clean", each [cost digits]*[cost k detector]),

// --- Calculate Total Sales--- 
    #"Fix Discount Nulls" = Table.ReplaceValue(#"Cost Clean",null,0,Replacer.ReplaceValue,{"Discount"}),
    #"Total Sales" = Table.AddColumn(#"Fix Discount Nulls", "Total_Sales_clean", each ([Quantity]*[Unit_Price_clean])*(1-[Discount]/100)),
// --- Calculate Profit--- 
    #"Profit" = Table.AddColumn(#"Total Sales", "Profit_clean", each [Total_Sales_clean]-[Cost_clean]),

// --- Finalize Dataset--- 
    #"Proper Data Types" = Table.TransformColumnTypes(#"Profit",{{"City_clean", type text}, {"Unit_Price_clean", type number}, {"Cost_clean", type number},{"Total_Sales_clean", type number},{"Profit_clean", type number}}),
    #"Removed Duplicates" = Table.Distinct(#"Proper Data Types"),
    #"Removed Helper Columns" = Table.SelectColumns(#"Removed Duplicates",{"Order_ID", "Order_Date", "Customer_Name", "Segment", "Region", "Product_ID", "Product_Name", "Category", "Quantity", "Payment_Type", "Sales_Rep", "Discount", "City_clean", "Unit_Price_clean", "Cost_clean", "Total_Sales_clean", "Profit_clean"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Helper Columns",{{"Profit_clean", "Profit"}, {"Total_Sales_clean", "Total_Sales"}, {"Cost_clean", "Cost"}, {"Unit_Price_clean", "Unit_Price"}, {"City_clean", "City"}})
in
    #"Renamed Columns"