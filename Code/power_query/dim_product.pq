let
    // Use the cleaned sales dataset as the source
    Source = Sales_Clean,

    // Keep only the fields needed for the Product dimension
    KeepColumns = Table.SelectColumns(Source, {"Product_ID", "Product_Name", "Category"}),

    // Remove missing or blank Product_ID values (cannot have null keys in a dimension)
    Filtered = Table.SelectRows(KeepColumns, each [Product_ID] <> null and Text.Trim([Product_ID]) <> ""),

    // Remove duplicate products so each product appears once
    DistinctProducts = Table.Distinct(Filtered),

    // Sort products to keep the table stable for refreshes and readability
    Sorted = Table.Sort(DistinctProducts, {{"Product_ID", Order.Ascending}}),

    // Ensure correct data types for relationships and visuals
    ChangeTypes = Table.TransformColumnTypes(Sorted, {
        {"Product_ID", type text},
        {"Product_Name", type text},
        {"Category", type text}
    })
in
    ChangeTypes