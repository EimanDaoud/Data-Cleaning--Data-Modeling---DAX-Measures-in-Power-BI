let
    Source = Sales_Clean,

    // Keep only needed columns
    KeepColumns = Table.SelectColumns(Source, {"Customer_Name", "Segment"}),

    // Remove null / blank names
    Filtered = Table.SelectRows(KeepColumns, each 
        Text.Trim([Customer_Name]?) <> "" and [Customer_Name] <> null
    ),

    // Remove duplicates 
    DistinctCustomers = Table.Distinct(Filtered),

    // Sort to make ID assignment stable
    Sorted = Table.Sort(DistinctCustomers, {{"Customer_Name", Order.Ascending}}),

    // Add Customer Surrogate Key
    AddCustomerID = Table.AddIndexColumn(Sorted, "Customer_ID", 1, 1, Int64.Type),

    // Ensure correct data types
    ChangeTypes = Table.TransformColumnTypes(AddCustomerID, {
        {"Customer_ID", Int64.Type},
        {"Customer_Name", type text},
        {"Segment", type text}
    })
in
    ChangeTypes