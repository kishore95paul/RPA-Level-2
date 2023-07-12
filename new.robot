*** Settings ***
Library    RPA.Archive

*** Tasks ***
Zip the Folder
    Archive Folder With Zip    ${OUTPUT_DIR}${/}Receipts    ${OUTPUT_DIR}${/}Receipts.zip  