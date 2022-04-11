*** Settings ***
Library       SeleniumLibrary
Test Setup        Open TodoMVC Page Using Chrome Browser
Test Teardown     Close Browser

*** Variables ***
${MAIN_PAGE}               https://todomvc.com/examples/react/#/
${TODO_INPUT_FIELD}        //input[@class='new-todo']
${FILTER_ELEMENT}          //ul[@class='filters']/li/a

*** Test Cases ***
Empty list can have item added
  GIVEN An empty Todo list
  WHEN I add a todo for           Buy cheese
  THEN Only that item is listed   Buy cheese
  AND The list summary is         1 item left
  AND The filter is set to        All
  AND The filter is unset to      Completed
  AND The filter is unset to      Active
  AND Clear completed is unavailable

Empty list can have two items added
  GIVEN an empty Todo list
  WHEN I add a todo for           Buy cheese 
  AND I add a todo for            Wash the car
  THEN Only that item is listed   Buy cheese
  AND Only that item is listed    Wash the car
  AND The list summary is         2 items left
  AND The filter is set to        All
  AND The filter is unset to      Completed
  AND The filter is unset to      Active
  AND Clear completed is unavailable

Item completion changes the list
  GIVEN a Todo list with items            File taxes       Walk the dog
  WHEN The item is marked as complete     File taxes
  THEN The item is listed as active       Walk the dog
  AND The list summary is                 1 item left
  AND Clear completed is available

Completed items should not be visible in active filter
  GIVEN a Todo list with items            File taxes       Walk the dog
  AND The item is marked as complete      File taxes
  WHEN The filter is set to               Active
  THEN The item is listed as active       Walk the dog
  AND The list summary is                 1 item left
  AND Clear completed is available
  And The route is                        /active

All completed items should not be visible in active filter
  GIVEN a Todo list with items            File taxes       Walk the dog
  AND The item is marked as complete      File taxes
  AND The item is marked as complete      Walk the dog
  WHEN The filter is set to               Active
  THEN Nothing is listed
  AND The list summary is                 0 items left
  AND Clear completed is available
  AND The route is                        /active

Uncompleted items should not be visible in the completed filter
  GIVEN a Todo list with items            File taxes       Walk the dog
  AND The item is marked as complete      File taxes
  WHEN The filter is set to               Completed
  THEN The item is listed as completed    File taxes
  AND The list summary is                 1 item left
  AND Clear completed is available
  AND The route is                        /completed

Items can be cleared
  GIVEN a Todo list with items            File taxes       Walk the dog
  AND The item is marked as complete      File taxes
  WHEN Clear completed is clicked
  THEN The item is listed as active       Walk the dog
  AND The list summary is                 1 item left

Clear all works when none completed
  GIVEN a Todo list with items            File taxes       Walk the dog
  WHEN The clear all items affordance is toggled
  THEN The item is listed as completed     File taxes
  AND The item is listed as completed      Walk the dog
  BUT Nothing listed is active
  AND The list summary is                 0 items left

Clear all works when one of two completed
  GIVEN a Todo list with items            File taxes       Walk the dog
  AND The item is marked as complete      File taxes
  WHEN The clear all items affordance is toggled
  THEN The item is listed as completed    File taxes
  AND The item is listed as completed     Walk the dog
  BUT Nothing listed is active
  AND The list summary is                 0 items left

Clear all un-clears when two of two completed
  GIVEN a Todo list with items            File taxes       Walk the dog
  AND The item is marked as complete      File taxes
  AND The item is marked as complete      Walk the dog
  WHEN The clear all items affordance is toggled
  THEN The item is listed as active       File taxes
  AND The item is listed as active        Walk the dog
  AND The list summary is                 2 items left

Items can be straight removed
  GIVEN I add a todo for                  File taxes
  WHEN The item is removed                File taxes
  THEN Nothing is listed

Initiation of editing takes away delete and complete affordances
  GIVEN I add a todo for                  File taxes
  WHEN The item is selected for edit      File taxes
  Then the item cannot be completed       File taxes
  And the item cannot be removed          File taxes


*** Keywords ***
Open TodoMVC Page Using Chrome Browser
  Open Browser    ${MAIN_PAGE}    Chrome
  Maximize Browser Window

An Empty Todo List
    Wait Until Element Is Visible         ${TODO_INPUT_FIELD}
    Wait Until Element Is Not Visible     //section[@class='main']

I add a todo for
  [Arguments]                         ${todo_item}
  Wait Until Element Is Enabled       ${TODO_INPUT_FIELD}
  Input Text                          ${TODO_INPUT_FIELD}       ${todo_item}
  Press Keys	                        ${TODO_INPUT_FIELD}       RETURN

Only that item is listed
  [Arguments]                         ${todo_item}
  Wait Until Element Is Visible       //label[text()='${todo_item}']

The list summary is
  [Arguments]                         ${item_left}
  Wait Until Element Is Visible       //footer//span[contains(., '${item_left}')]

The filter is set to
  [Arguments]                         ${filter_name}
  Click Link                          ${FILTER_ELEMENT} [text()='${filter_name}']
  Wait until page contains element    ${FILTER_ELEMENT} [text()='${filter_name}'][contains(@class, 'selected')]

The filter is unset to
  [Arguments]                         ${filter_name}
  Wait until page contains element    ${FILTER_ELEMENT} [text()='${filter_name}'][contains(@class, '')]

Clear completed is unavailable
  Wait Until Element Is Not Visible     //button[text()='Clear completed']

Clear completed is available
  Wait Until Element Is Visible     //button[text()='Clear completed']

A Todo list with items
  [Arguments]                         ${item1}   ${item2}
  I add a todo for   ${item1}
  I add a todo for   ${item2}

The item is marked as complete
  [Arguments]                          ${item}
  Click Button                         //label[text()='${item}']//preceding-sibling::input[@type='checkbox']
  Wait until page contains element     //label[text()='${item}']//ancestor::li[contains(@class, 'completed')]

The item is listed as active
  [Arguments]                         ${item}
  Wait until page contains element    //label[text()='${item}']//ancestor::li[contains(@class, '')]

The item is listed as completed
  [Arguments]                         ${item}
  Wait until page contains element    //label[text()='${item}']//ancestor::li[contains(@class, 'completed')]

The route is
  [Arguments]                         ${route}
  Location Should Contain             ${route}

Nothing is listed
  Wait Until Element Is Not Visible     //ul[@class='todo-list']

Clear completed is clicked
  Click Button                          //button[@class='clear-completed']

The clear all items affordance is toggled
  Click Element                         //input[@id='toggle-all']//following-sibling::label

Nothing listed is active
  Wait Until Element Is Not Visible     //ul[@class='todo-list']/li[@class='']

The item is removed
  [Arguments]                         ${item}
  Mouse Over                          //label[text()='${item}']//ancestor::li
  Click Button                        //label[text()='${item}']//ancestor::li//button[@class='destroy']

The item is selected for edit
  [Arguments]                         ${item}
  Double Click Element                       //label[text()='${item}']
  # //ancestor::li

The item cannot be completed
  [Arguments]                         ${item}
  Wait Until Page Does Not Contain Element    //label[text()='${item}']//ancestor::li[contains(@class, 'completed')]

The item cannot be removed
  [Arguments]                         ${item}
  Mouse Over                                 //label[text()='${item}']//ancestor::li
  Wait Until Element Is Not Visible          //label[text()='${item}']//ancestor::li//button[@class='destroy']
