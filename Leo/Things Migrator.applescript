-- Things Migrator
--  Created by Martin Jacobsen

set deleteThings to state of button "deleteDataCheck" of window 1
set addFromTag to state of button "addFromThingsTag" of window 1
set mapAreasTo to "@contexts"
on launched theObject
	
end launched

on clicked theObject
	set deleteThings to state of button "deleteDataCheck" of window 1
	set addFromThingsTag to state of button "addFromThingsTag" of window 1
	set mapAreasTo to (title of current menu item of popup button 1 of window 1) as string
	doTransferItems(mapAreasTo, addFromThingsTag, deleteThings)
end clicked

on choose menu item theObject
	set mapAreasTo to (title of current menu item of theObject) as string
end choose menu item

on awake from nib theObject
	
	tell window 1
		
		set title of button "goButton" to "Go!"
		
		set thePopupItems to {"@contexts", "/tags", "/area tags/", "discard"}
		tell menu of popup button "areasMapToMenu"
			delete every menu item
			repeat with aMenuItem in thePopupItems
				make new menu item at end of menu items with properties {title:aMenuItem}
			end repeat
		end tell
	end tell
end awake from nib

on doTransferItems(areasBecome, addFromTag, willDeleteOld)
	
	tell application "Things"
		try
			set inboxitemslist to every to do whose status is open
			
			if (count of inboxitemslist) is greater than 0 then
				repeat with listitem in inboxitemslist
					set theName to name of listitem
					if due date of listitem is not missing value then
						set theDueDate to (due date of listitem) as date
					else
						set theDueDate to "null"
					end if
					
					if project of listitem is not missing value then
						set theProject to name of project of listitem
					else
						set theProject to "null"
					end if
					
					set theRawTags to tag names of listitem as string
					set oldDelim to ""
					set AppleScript's text item delimiters to ","
					set theRawTags to every text item in theRawTags
					
					set AppleScript's text item delimiters to oldDelim
					set theTags to ""
					if (count of theRawTags) is greater than 1 then
						repeat with aRawTag in theRawTags
							if aRawTag contains " " then
								set newRT to "/" & aRawTag & "/ " as string
							else
								set newRT to "/" & aRawTag & " " as string
							end if
							set theTags to theTags & " " & newRT
						end repeat
					end if
					if theTags contains "/ " then
						set oldDelim to AppleScript's text item delimiters
						set AppleScript's text item delimiters to "/ "
						set theStrippedTags to every text item in theTags
						set AppleScript's text item delimiters to "/"
						set theTags to every item in theStrippedTags as string
						set AppleScript's text item delimiters to ""
					end if
					
					
					if area of listitem is not missing value then
						set aname to name of area of listitem as string
						if areasBecome is "@contexts" then
							set areaname to "@" & aname
						else if areasBecome is "/area tags/" then
							set areaname to "/area " & aname & "/"
						else if areasBecome is "/tags" then
							set areaname to "/" & aname
						else
							set areaname to ""
						end if
						
					else
						set areaname to ""
					end if
					set nameAndTags to theName & " " & areaname & " " & theTags
					
					set rawNote to notes of listitem
					if rawNote is not missing value then
						set endOfNote to offset of "</note>" in rawNote
						set theNote to texts 28 thru (endOfNote - 1) of rawNote as text
					else
						set theNote to ""
					end if
					
					if theNote contains "<alias " then
						set theLinkStart to offset of "<alias" in theNote
						set theLinkStop to offset of "</alias>" in theNote
						set theLink to texts (theLinkStart - 1) thru (theLinkStop + 7) of theNote as text
						
						set oldDelim to AppleScript's text item delimiters
						set AppleScript's text item delimiters to theLink
						set theStrippedNote to every text item in theNote
						set AppleScript's text item delimiters to ""
						set theNote to every item in theStrippedNote as string
						set theNote to theNote & " [!!Link to file removed by migrator!!]"
						set AppleScript's text item delimiters to ""
					end if
					
					tell application "The Hit List"
						if theProject is not "null" then
							tell folders group
								if exists (first folder whose name is "Things Export") then
									set thingsExportFolder to (first folder whose name is "Things Export")
								else
									set thingsExportFolder to make new folder with properties {name:"Things Export"}
								end if
								
								tell thingsExportFolder
									if exists (first list whose name is theProject) then
										set theList to (first list whose name is theProject)
									else
										set theList to make new list with properties {name:theProject}
									end if
									
								end tell
							end tell
						else
							set theList to inbox
						end if
						if (class of listitem as string) is not "project" then
							if addFromTag is 1 then
								set nameAndTags to nameAndTags & " /imported from Things/"
							end if
							
							set props to {title:nameAndTags, notes:theNote}
							if theDueDate is not "null" then
								set props to props & {due date:theDueDate}
							end if
							
							tell theList to set myResult to ¬
								make new task with properties props
						end if
					end tell
					
				end repeat
				--	delete every to do in inboxList
				tell application "GrowlHelperApp"
					set the allNotificationsList to ¬
						{"Pack your Things"}
					set the enabledNotificationsList to ¬
						{"Pack your Things"}
					register as application ¬
						"Pack your Things" all notifications allNotificationsList ¬
						default notifications enabledNotificationsList ¬
						icon of application "The Hit List"
					notify with name ¬
						"Pack your Things" title ¬
						"Pack your Things" description ¬
						¬
							"The Hit List Updated. 
 Things Purged. 
 Have a nice day" as text application name "Pack your Things"
				end tell
			else
				error
			end if
		on error
			tell application "GrowlHelperApp"
				set the allNotificationsList to ¬
					{"Pack your Things"}
				set the enabledNotificationsList to ¬
					{"Pack your Things"}
				register as application ¬
					"Pack your Things" all notifications allNotificationsList ¬
					default notifications enabledNotificationsList ¬
					icon of application "The Hit List"
				notify with name ¬
					"Pack your Things" title ¬
					"Pack your Things" description ¬
					¬
						"Something went wrong. Sorry." application name "Pack your Things"
			end tell
		end try
	end tell
	
end doTransferItems