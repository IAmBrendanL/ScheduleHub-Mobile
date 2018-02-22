# ScheduleHub-Mobile
## Overview
An iOS app written in Swift 4. It is intended to facilitate finding times that groups of people are all available. It is still a work in progress.

### Users will be able to:
* Create and use accounts on the ScheduleHub-Web project
* Create and join groups
* Enter their own available times
* Create role accounts for people who are not part of the service and enter their available times for them

### Users will get:
* Automatically generated times when all users in a group (or all users - some amount they chose) are available
* An automatically generated calendar event when they select a specific time when users in a group are availible 
* The ability to denote selected times

## Current State
The current build is completely decoupled from ScheduleHub-Web. There is the ability to import and export user data as a JSON file which will be used during integration with the webservice.

### Users can:
* Create Groups
* Create role accounts in groups
* Add available times for role accounts
* Export and import JSON representations of users 

### Users can get:
* Automatically generated times when all users in a group (or all users - some amount they chose) are available
* An automatically generated calendar event when they select a specific time when users in a group are availible 
