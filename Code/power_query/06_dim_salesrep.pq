let
    // Use the cleaned dataset as the source
    Source = Sales_Clean,

    // Keep only the Sales_Rep column
    KeepColumns = Table.SelectColumns(Source, {"Sales_Rep"}),

    // Remove blank or null sales rep names
    Filtered = Table.SelectRows(KeepColumns, each 
        [Sales_Rep] <> null and Text.Trim([Sales_Rep]) <> ""
    ),

    // Remove duplicate sales rep names
    DistinctReps = Table.Distinct(Filtered),

    // Sort to ensure stable ID assignment
    Sorted = Table.Sort(DistinctReps, {{"Sales_Rep", Order.Ascending}}),

    // Add surrogate Sales_Rep_ID starting from 1
    AddRepID = Table.AddIndexColumn(Sorted, "Sales_Rep_ID", 1, 1, Int64.Type),

    // Assign correct data types
    ChangeTypes = Table.TransformColumnTypes(AddRepID, {
        {"Sales_Rep_ID", Int64.Type},
        {"Sales_Rep", type text}
    })
in
    ChangeTypes