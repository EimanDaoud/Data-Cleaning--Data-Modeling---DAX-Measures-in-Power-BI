(dateStart as date, dateEnd as date) =>
let
    // Generate list of dates between start and end
    Source = List.Dates(
        dateStart,
        Duration.Days(dateEnd - dateStart) + 1,
        #duration(1,0,0,0)
    ),

    // Convert to table
    TableFromList = Table.FromList(Source, Splitter.SplitByNothing(), {"Date"}, null, ExtraValues.Error),

    // Add columns
    AddYear = Table.AddColumn(TableFromList, "year", each Date.Year([Date]), Int64.Type),
    AddMonthNumber = Table.AddColumn(AddYear, "month number", each Date.Month([Date]), Int64.Type),
    AddMonth = Table.AddColumn(AddMonthNumber, "month", each Date.MonthName([Date])),
    AddMonthShort = Table.AddColumn(AddMonth, "month short", each Text.Start(Date.MonthName([Date]), 3)),
    AddMonthYear = Table.AddColumn(AddMonthShort, "month year", each [month short] & ", " & Text.From([year])),
    AddDay = Table.AddColumn(AddMonthYear, "day", each Date.Day([Date]), Int64.Type),
    AddDayName = Table.AddColumn(AddDay, "day name", each Date.DayOfWeekName([Date])),
    AddDayNameShort = Table.AddColumn(AddDayName, "day name short", each Text.Start([day name], 3)),
    AddWeekdayNumber = Table.AddColumn(AddDayNameShort, "weekday number", each Date.DayOfWeek([Date], Day.Sunday) + 1, Int64.Type),
    AddQuarter = Table.AddColumn(AddWeekdayNumber, "quarter", each Date.QuarterOfYear([Date]), Int64.Type),

    // Organize columns neatly
    Final = Table.ReorderColumns(AddQuarter, {
        "Date", "year", "month", "month number", "month short", 
        "month year", "day", "day name", "day name short", 
        "weekday number", "quarter"
    })
in
    Final