# How Long Left Kit

This project contains the core functionality of How Long Left, my app avaliable for macOS, iOS and watchOS. This is currently a WIP rewrite.

## Main Features

- Classes for fetching and storing events from the user's calendar.
- "TimePoint", a representation of the in progress and upcoming events at a given point in time. A UI can be designed to display infomation based on a TimePoint, and an array of TimePoints could be used to pregenerate a timeline of states.
- Classes for persistently storing event identifying info. An instance can be used to track hidden events and another to track pinned events.
- Classes for persistently storing calendar info, for tracking enabled calendars, for example. A calendar can have any number of custom states, more than just "on or off". Multiple calendar storage domains can be created as well.
- "DefaultContainer" provides a default implementation for a set of core dependencies, like a CalendarSource, EventCache, EventFetchSettingsManager, TimePointStore. Likely to be subclassed in more complex app implementations. 
- More I might add later idk.
