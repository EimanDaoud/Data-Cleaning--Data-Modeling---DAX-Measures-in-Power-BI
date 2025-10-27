let
    // Use the cleaned dataset
    Source = Sales_Clean,

    // Keep only Payment_Type column for the Payment Dimension
    KeepColumns = Table.SelectColumns(Source, {"Payment_Type"}),

    // Remove blank and null payment types
    Filtered = Table.SelectRows(KeepColumns, each 
        [Payment_Type] <> null and Text.Trim([Payment_Type]) <> ""
    ),

    // Remove duplicate payment methods
    DistinctPayments = Table.Distinct(Filtered),

    // Sort to ensure stable index assignment on refresh
    Sorted = Table.Sort(DistinctPayments, {{"Payment_Type", Order.Ascending}}),

    // Add surrogate key starting from 1
    AddPaymentID = Table.AddIndexColumn(Sorted, "Payment_Method_ID", 1, 1, Int64.Type),

    // Assign correct data types
    ChangeTypes = Table.TransformColumnTypes(AddPaymentID, {
        {"Payment_Method_ID", Int64.Type},
        {"Payment_Type", type text}
    })
in
    ChangeTypes