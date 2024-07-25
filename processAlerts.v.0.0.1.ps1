#Last modification date: 2024-07-25

function Update-Record {
    param (
        [string]$recordId
    )

    # Find the record with the specified ID
    $recordToUpdate = $allRecords | Where-Object { $_.ID -eq $recordId }
    $CustomID = $recordToUpdate.CustomID
    # Check if the status is "Processed"
    if ($recordToUpdate.Status -ne "Processed") {
        # Update other fields (if needed)
        $recordToUpdate.LastUpdatedTimestamp = Get-Date
        $recordToUpdate.RetryCount = [int]$recordToUpdate.RetryCount
        $recordToUpdate.RetryCount++
        $recordToUpdate.Status = "Processed"

        # Save the updated data back to the file
        $allRecords | Export-Csv -Path "records.csv" -NoTypeInformation

        # Show a message
        Write-Host "Record with ID ${CustomID} has been processed."
    } else {
        Write-Host "Record with ID ${CustomID} is already processed."
    }

}

# Load all records from the CSV file
$allRecords = Import-Csv -Path "records.csv"

function New-Record {
    param (
        [string]$customId,
        [int]$retryCount,
        [string]$status
    )

    # Create a new record
    $newRecord = [PSCustomObject]@{
        ID = [Guid]::NewGuid()
        CustomID = $customId
        CreatedTimestamp = Get-Date
        LastUpdatedTimestamp = $null
        RetryCount = $retryCount
        Status = $status
    }

    # Append the new record to the CSV file
    $newRecord | Export-Csv -Path "records.csv" -Append -NoTypeInformation

    Write-Host "New record with CustomID '$customId' has been inserted."
}

function Show-RecordList {
    param (
        [string]$recordId
    )

    # Display a numbered list of records
    $recordNumber = 1
    $recordChoices = @{}
    foreach ($record in $allRecords) {
        Write-Host "$recordNumber) $($record.CustomID)"
        $recordChoices[$recordNumber] = $record.ID
        $recordNumber++
    }

    # Prompt the user for input
    $selectedNumber = Read-Host "Enter the record number (or 0 to exit):"
    if ($selectedNumber -eq "0") {
        Write-Host "Exiting record selection."
        return
    }

    # Get the selected record ID
    if ($recordChoices.ContainsKey([int]$selectedNumber)) {
        $selectedRecordId = $recordChoices[[int]$selectedNumber]
        Update-Record -recordId $selectedRecordId
    } else {
        Write-Host "Invalid selection. Please choose a valid record number."
    }
}

$newCustomID = [Guid]::NewGuid()
New-Record -customId "NH-${newCustomID}" -retryCount 0 -status "Pending"

# Load all records from the CSV file
$allRecords = Import-Csv -Path "records.csv"

Show-RecordList

