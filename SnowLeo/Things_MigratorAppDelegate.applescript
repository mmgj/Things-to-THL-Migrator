--
--  Things_MigratorAppDelegate.applescript
--  Things Migrator
--
--  Created by Martin Jacobsen on 13.12.09.
--  Do what thou wilt shall be the only law.
--

script Things_MigratorAppDelegate
	property parent : class "NSObject"
	property deleteStuffCheck : missing value
	property addTagsCheck : missing value
	property mapAreasTo : missing value
	property spinner : missing value
	
	
	on applicationWillFinishLaunching_(aNotification)
		-- Insert code here to initialize your application before any files are opened 
	end applicationWillFinishLaunching_
	
	on applicationShouldTerminate_(sender)
		-- Insert code here to do any housekeeping before your application quits 
		return current application's NSTerminateNow
	end applicationShouldTerminate_
	
	on applicationShouldTerminateAfterLastWindowClosed_(sender)
		return true
	end applicationShouldTerminateAfterLastWindowClosed_
	
	on goClicked_(sender)
		performSelector_withObject_afterDelay_("processInfo:", sender, 0.0)
		
	end goClicked_
	
	on processInfo_(sender)
		spinner's setUsesThreadedAnimation_(true)
		
		set doMapAreas to mapAreasTo's title as string
		set doDeleteStuff to state of deleteStuffCheck
		set doAddTags to state of addTagsCheck
		
		tell application "Things"
			empty trash
			try
				set exportItemList to every to do whose status is open
				spinner's setMaxValue_(length of exportItemList)
				if (count of exportItemList) is greater than 0 then
					repeat with exportListItem in exportItemList
						set todoTitle to name of exportListItem
						if due date of exportListItem is not missing value then
							set theDueDate to (due date of exportListItem) as date
						else
							set theDueDate to "null"
						end if
						
						if project of exportListItem is not missing value then
							set theProject to name of project of exportListItem
						else
							set theProject to "null"
						end if
						
						set exportTags to tag names of exportListItem as string
						set oldDelim to ""
						set AppleScript's text item delimiters to ","
						set exportTags to every text item in exportTags
						
						set AppleScript's text item delimiters to oldDelim
						set importTags to ""
						if (count of exportTags) is greater than 1 then
							repeat with parseTag in exportTags
								if parseTag contains " " then
									set importTag to "/" & parseTag & "/ " as string
								else
									set importTag to "/" & parseTag & " " as string
								end if
								set importTags to importTags & " " & importTag
							end repeat
						end if
						if importTags contains "/ " then
							set oldDelim to AppleScript's text item delimiters
							set AppleScript's text item delimiters to "/ "
							set strippedTags to every text item in importTags
							set AppleScript's text item delimiters to "/"
							set importTags to every item in strippedTags as string
							set AppleScript's text item delimiters to ""
						end if
						
						
						if area of exportListItem is not missing value then
							set thingsAreaName to name of area of exportListItem as string
							if doMapAreas is "@contexts" then
								set thlAreaName to "@" & thingsAreaName
							else if doMapAreas is "/area tags/" then
								set thlAreaName to "/area " & thingsAreaName & "/"
							else if doMapAreas is "/tags" then
								set thlAreaName to "/" & thingsAreaName
							else
								set thlAreaName to ""
							end if
							
						else
							set thlAreaName to ""
						end if
						set nameAndTags to todoTitle & " " & thlAreaName & " " & importTags
						
						set rawNote to notes of exportListItem
						if rawNote is not missing value then
							set theNote to rawNote
						else
							set theNote to ""
						end if
						
						set theProject to "Needs Sorting"
						
						tell application "The Hit List"
							if theProject is not "null" then
								tell folders group
									if exists (first folder whose name is "Imported Things") then
										set thingsExportFolder to (first folder whose name is "Imported Things")
									else
										set thingsExportFolder to make new folder with properties {name:"Imported Things"}
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
							if (class of exportListItem as string) is not "project" then
								if doAddTags is 1 then
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
						
						spinner's incrementBy_(1)
						
					end repeat
				end if
				if doDeleteStuff is 1 then
					tell application "Things" to delete every to do
				end if
				spinner's setHidden_(true)
				tell application "The Hit List" to activate
				
				tell me to quit
				
			end try
			
			
			
		end tell
		
		
	end processInfo_
	
end script