SELECT Description, (SELECT ListLabel FROM ListItem WHERE ListID = 2 AND ListValue = UnitOfMeasure) 'Unit of Measure' FROM ServiceType
