let
    // Start from the cleaned transactional dataset
    Source = Sales_Clean,

    // Join Customer Dimension
    MergeCustomer = Table.NestedJoin(Source, {"Customer_Name", "Segment"}, DimCustomer, {"Customer_Name", "Segment"}, "DimCustomer", JoinKind.LeftOuter),
    ExpandCustomer = Table.ExpandTableColumn(MergeCustomer, "DimCustomer", {"Customer_ID"}, {"Customer_ID"}),

    // Join Store Dimension
    MergeStore = Table.NestedJoin(ExpandCustomer, {"Region", "City"}, DimStore, {"Store_Region", "Store_City"}, "DimStore", JoinKind.LeftOuter),
    ExpandStore = Table.ExpandTableColumn(MergeStore, "DimStore", {"Store_ID"}, {"Store_ID"}),

    // Join Payment Dimension
    MergePayment = Table.NestedJoin(ExpandStore, {"Payment_Type"}, DimPayment, {"Payment_Type"}, "DimPayment", JoinKind.LeftOuter),
    ExpandPayment = Table.ExpandTableColumn(MergePayment, "DimPayment", {"Payment_Method_ID"}, {"Payment_Method_ID"}),

    // Join Sales Rep Dimension
    MergeSalesRep = Table.NestedJoin(ExpandPayment, {"Sales_Rep"}, DimSalesRep, {"Sales_Rep"}, "DimSalesRep", JoinKind.LeftOuter),
    ExpandSalesRep = Table.ExpandTableColumn(MergeSalesRep, "DimSalesRep", {"Sales_Rep_ID"}, {"Sales_Rep_ID"}),

    // Select only fact table columns (measures + foreign keys)
    SelectColumns = Table.SelectColumns(ExpandSalesRep,{
        "Order_ID", "Order_Date", "Product_ID", "Quantity", "Unit_Price", "Discount",
        "Total_Sales", "Cost", "Profit",
        "Customer_ID", "Store_ID", "Payment_Method_ID", "Sales_Rep_ID"
    }),

    // Ensure foreign keys match dimension type
    ChangeTypes = Table.TransformColumnTypes(SelectColumns, {
        {"Customer_ID", Int64.Type},
        {"Store_ID", Int64.Type},
        {"Payment_Method_ID", Int64.Type},
        {"Sales_Rep_ID", Int64.Type},
        {"Product_ID", type text} // important for relationship stability
    })
in
    ChangeTypes