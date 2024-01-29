(
    [Parameter(Mandatory=$False)]       [String]$numFiles,
    [Parameter(Mandatory=$True)]        [String]$s3BucketPath,
    [Parameter(Mandatory=$False)]       [Int]$numRecords,
    [Parameter(Mandatory=$True)]        [String]$type

)

function New-RandomS3DataFiles {
    param(
        [int] $numFiles,
        [string] $s3BucketPath,
        [string] $numRecords,
        [string] $type
    )
    if($numFiles -lt 0) {
        $numFiles = 200;
        Write-Host "A number of files was not provided, so we will use a default of 200";
    }
    $pathTerminator = $s3BucketPath.Substring($s3BucketPath.Length -1);
    if(($s3BucketPath -eq $null) -or ($pathTerminator -ne "/")) {
        Write-Host "S3 Bucket Path is incorrect";
    }
    $s3bucket = "s3://"+$s3BucketPath;
    #separate bucket name from bucket path
    $bucketName = $s3BucketPath.Substring(0,$s3BucketPath.IndexOf("/"));
    $prefix = $s3BucketPath.Substring($bucketName.Length,$s3BucketPath.Length-1);
    #createRandomFile;
    for ($i=0; $i -lt $numFiles; $i++) {
        import-module AWSPowerShell.NetCore;
        if($type -eq "demographic") {
            $file = New-RandomDemographicData -numRecords $numRecords -outputFile randemo.json -outputFormat JSON;
        }
        if($type -eq "binary") {
            $file = New-RandomBinaryData -maxSize 1800
        }

        # Write-S3Object -File ./$fileName -KeyPrefix $prefix -BucketName $bucketName;
        aws s3 mv ./$file $s3bucket
    }

}
function New-RandomDemographicData {
    param(
        [int] $numRecords,
        [string] $outputFile,
        [string] $outputFormat
    )
    #base URL for web request. Size defines the number of records in the result set. This is provided as JSON.
    $baseURL = "https://random-data-api.com/api/v2/users?size=100"
    if(numRecords -gt 100) { $numRecords = 100; Write-Host "Number of records cannot exceed 100"; }
    if(numRecords -lt 1) { $numRecords = 1; Write-Host "Number of records cannot be less than 1"; }
    if($numRecords -eq $null) {$numRecords = 50; }
    #Request Records
    $rawDataFeed = Invoke-RestMethod -Uri "$baseURL$numRecords";
    if($outputFile -ne $null) {
        if($outputFormat -eq "JSON" ) {
            $rawDataFeed | Out-File ./$outputFile;
        }
        if($outputFormat -eq "CSV") {
            $jsonData = $rawDataFeed | ConvertFrom-Json;
            $csvData = $jsonData | ConvertTo-Csv -UseQuotes AsNeeded;
            $csvData | Out-File ./$outputFile;
        }
    } else {
        #should this be simplified with a case switch statement?
        $rawDataFeed | Out-File ./$outputFile;
        Write-Host "Supported formats include CSV and JSON. The default of JSON has been chosen";
    }
    return $outputFile;   
}
function New-RandomBinaryData {
    param(
        [int] $maxSize,
        [string] $fileNameprefix
    )
    #create random binary files
    $size = Get-Random -Minimum 1 -Maximum $maxSize;
    $fileName = $fileNameprefix+[String]$size+"M-file.random";
    $out = New-Object byte[] ($size*1MB);
    (New-Object random).NextBytes($out);
    #Write File to File System
    [IO.File]::WriteAllBytes($fileName, $out);
    return $fileName;
}
New-RandomS3DataFiles -numFiles $numFiles -s3BucketPath $s3BucketPath -numRecords $numRecords -type $type;