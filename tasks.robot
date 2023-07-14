*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.HTTP
Library             RPA.Browser.Selenium    # auto_close=${False}
Library             RPA.RobotLogListener
Library             RPA.PDF
Library             String
Library             OperatingSystem
Library             RPA.Archive


*** Variables ***
${Download_Dir}=    ${CURDIR}/Output/Download


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Download the Orders file
    Open the robot order website
    Fill the Form using Excel Data
    [Teardown]    Zip the Folder


*** Keywords ***
Download the Orders file
    Set Download Directory    ${Download_Dir}
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=${True}    target_file=${Download_Dir}

Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Click Button    OK

Add image to PDF
    [Arguments]    ${id}    ${image}    ${pdf_raw}
    ${pdf_file}=    Create List    ${image}:align=center
    Add Files To Pdf    ${pdf_file}    ${pdf_raw}    append=True

Save and Convert
    [Arguments]    ${id}
    Click Button    id:order
    ${receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt}    ${OUTPUT_DIR}${/}Receipts/${id}.pdf
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}Images/${id}.jpg
    Add image to PDF    ${id}    ${OUTPUT_DIR}${/}Images/${id}.jpg    ${OUTPUT_DIR}${/}Receipts/${id}.pdf

Fill the Order Details
    [Arguments]    ${order}
    Select From List By Value    id:head    ${order}[1]
    Select Radio Button    body    ${order}[2]
    Input Text    class:form-control    ${order}[3]
    Input Text    id:address    ${order}[4]
    Click Button    id:preview
    Mute Run On Failure    Save and Convert
    # It will try the Keyword untill it succeeds no of times & in intervals
    Wait Until Keyword Succeeds
    ...    10x
    ...    1s
    ...    Save and Convert
    ...    ${order}[0]
    Click Button    id:order-another
    Click Button    OK

Fill the Form using Excel Data
    ${csv_table_data}=    Get File    ${OUTPUT_DIR}${/}Download/orders.csv
    @{list_of_orders}=    Create List    ${csv_table_data}
    # Starting from row 2 not including header and converting every row to string
    @{order_list}=    Split To Lines
    ...    @{list_of_orders}
    ...    1
    FOR    ${row_data}    IN    @{order_list}
        # spliting the row string into list of words using , as separator
        ${row_value}=    Split String
        ...    ${row_data}
        ...    ,
        Fill the Order Details    ${row_value}
        # ${order_number}=    Set Variable    ${row_value}[0]
        # ${head}=    Set Variable    ${row_value}[1]
        # ${body}=    Set Variable    ${row_value}[2]
        # ${leg}=    Set Variable    ${row_value}[3]
        # ${address}=    Set Variable    ${row_value}[4]
        # Log Many    ${order_number}    ${head}    ${body}    ${leg}    ${address}
    END

Zip the Folder
    Archive Folder With Zip    ${OUTPUT_DIR}${/}Receipts    ${OUTPUT_DIR}${/}Receipts.zip
