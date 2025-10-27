let
    Source = #"Date Table Generator"(#date(2023, 1, 1), #date(2025, 12, 31)),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"Date", type date}, {"month", type text}, {"month short", type text}, {"month year", type text}, {"day name", type text}, {"day name short", type text}})
in
    #"Changed Type"