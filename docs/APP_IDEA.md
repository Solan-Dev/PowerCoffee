# App idea: PowerCoffee (Solution-based)

## Summary
A coffee tasting notes system that demonstrates Dataverse, model-driven, and canvas app capabilities, aligned with ALM best practices.

## Dataverse tables
Table: `pc_tastingnote`
- Note Number (Auto number)
- Coffee Name (Text)
- Roaster (Text)
- Origin (Choice: Ethiopia, Colombia, Kenya, Brazil, Other)
- Process (Choice: Washed, Natural, Honey, Experimental)
- Roast Level (Choice: Light, Medium, Dark)
- Brew Method (Choice: Pour-over, Espresso, AeroPress, French Press, Other)
- Rating (Whole number 1–10)
- Tasting Notes (Text)
- Brew Date (Date)
- Brewed By (User)

Table: `pc_roastery` (optional)
- Roastery Name (Text)
- Website (URL)
- Location (Text)

## Model-driven app (admin)
- Manage tasting notes, roasteries, choices, and reference data
- Views by Origin, Roast Level, and Rating
- Add a chart for ratings by origin

## Canvas app (taster)
- Home screen: recent notes (filter by Brew Method)
- New tasting note screen
- My notes screen

## Environment variables
- `pc_default_brewer` (User or Team)
- `pc_default_roast_level` (Choice)

## Connection references
- Dataverse connection (required)
- Optional Outlook/Teams if you want notifications later
