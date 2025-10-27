let
    // Use the cleaned dataset as the source
    Source = Sales_Clean,

    // Keep only the fields related to store location
    KeepColumns = Table.SelectColumns(Source, {"Region", "City"}),

    // Remove rows where store location information is missing
    Filtered = Table.SelectRows(KeepColumns, each 
        [Region] <> null and Text.Trim([Region]) <> "" and
        [City] <> null and Text.Trim([City]) <> ""
    ),

    // Remove duplicate region/city combinations
    DistinctStores = Table.Distinct(Filtered),

    // Sort to ensure stable index assignment across refreshes
    Sorted = Table.Sort(DistinctStores, {{"Region", Order.Ascending}, {"City", Order.Ascending}}),

    // Create Surrogate Key (Store_ID)
    AddStoreID = Table.AddIndexColumn(Sorted, "Store_ID", 1, 1, Int64.Type),
    // Assign correct data types
    ChangeTypes = Table.TransformColumnTypes(AddStoreID, {
        {"Store_ID", Int64.Type},
        {"Region", type text},
        {"City", type text}
    }),
    // Cleaner fields names
    #"Renamed Columns" = Table.RenameColumns(ChangeTypes,{{"Region", "Store_Region"}, {"City", "Store_City"}})
in
    #"Renamed Columns"