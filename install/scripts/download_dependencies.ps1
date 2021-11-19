<#
# Old School
function DownloadFile($url, $targetFile)
{
   $uri = New-Object "System.Uri" $url
   
   $targetStream   = $null
   $responseStream = $null

   try {
       $request = [System.Net.HttpWebRequest]::Create($uri)
       $request.set_Timeout(15000) #15 second timeout

       $response = $request.GetResponse()

       $responseStream = $response.GetResponseStream()
       $targetStream   = New-Object -TypeName System.IO.FileStream -ArgumentList $targetFile, Create

       $buffer = new-object byte[] 64KB

       $totalLength     = [System.Math]::Floor($response.get_ContentLength()/1024)
       $bytesRead       = $responseStream.Read($buffer, 0, $buffer.length)
       $downloadedBytes = $bytesRead

       while ($bytesRead -gt 0)
       {
           $targetStream.Write($buffer, 0, $bytesRead)

           $bytesRead       = $responseStream.Read($buffer, 0, $buffer.length)
           $downloadedBytes = $downloadedBytes + $bytesRead

           Write-Progress -activity "Downloading file '$($url.split('/') | Select -Last 1)'" `
                          -status "Downloaded ($([System.Math]::Floor($downloadedBytes/1024))K of $($totalLength)K): " `
                          -PercentComplete ((([System.Math]::Floor($downloadedBytes/1024)) / $totalLength)  * 100)
       }

        Write-Progress -activity "Finished downloading file '$($url.split('/') | Select -Last 1)'"
    }
    catch [System.Net.WebException],[System.IO.IOException] {
        "Unable to download {$targetFile} from {$url}."
    }
    catch {
        "An error occurred that could not be resolved."
    }

    if ($targetStream -ne $null)
    {
        $targetStream.Flush()
        $targetStream.Close()
        $targetStream.Dispose()
    }

    if ($responseStream -ne $null)
    {
        $responseStream.Dispose()
    }
}
#>

<#
# Cool kids way. A bit busted and totally unncessary

function DownloadFile($url, $targetFile)
{
   Add-Type -AssemblyName System.Net.Http

   $uri = New-Object "System.Uri" $url
   
   $targetStream   = $null
   $responseStream = $null

   try {
       $client = [System.Net.Http.HttpClient]::new()
       $client.set_Timeout(15000) #15 second timeout

       $response  = $client.GetAsync($uri).GetAwaiter().GetResult()
       $response.EnsureSuccessStatusCode();
       $content = response.Content;

       $responseStream = $content.ReadAsStreamAsync().GetAwaiter().GetResult()
       $targetStream   = New-Object -TypeName System.IO.FileStream -ArgumentList $targetFile, Create

       $buffer = new-object byte[] 64KB

       $totalLength     = [System.Math]::Floor($content.get_ContentLength()/1024)
       $bytesRead       = $responseStream.Read($buffer, 0, $buffer.length)
       $downloadedBytes = $bytesRead

       while ($bytesRead -gt 0)
       {
           $targetStream.Write($buffer, 0, $bytesRead)

           $bytesRead       = $responseStream.Read($buffer, 0, $buffer.length)
           $downloadedBytes = $downloadedBytes + $bytesRead

           Write-Progress -activity "Downloading file '$($url.split('/') | Select -Last 1)'" `
                          -status "Downloaded ($([System.Math]::Floor($downloadedBytes/1024))K of $($totalLength)K): " `
                          -PercentComplete ((([System.Math]::Floor($downloadedBytes/1024)) / $totalLength)  * 100)
       }

        Write-Progress -activity "Finished downloading file '$($url.split('/') | Select -Last 1)'"
    }
    catch [System.Net.WebException],[System.IO.IOException] {
        "Unable to download {$targetFile} from {$url}."
    }
    catch {
        Write-Output "An error occurred that could not be resolved. "
        Write-Output $_
    }

    if ($targetStream -ne $null)
    {
        $targetStream.Flush()
        $targetStream.Close()
        $targetStream.Dispose()
    }

    if ($responseStream -ne $null)
    {
        $responseStream.Dispose()
    }
}
#>

function DownloadAndExtract($URL, $NAME){

    Write-Host -NoNewline "Downloading" $NAME "..."    # "from" $URL "..."

    try {
        # Invoke-WebRequest -Uri $URL -OutFile $NAME".zip"          # Doesn't provide progress as %
        Start-BitsTransfer -Source $URL -Destination $NAME".zip"
    }
    catch {
        "An error occurred that could not be resolved."
    }

    # DownloadFile $URL $NAME".zip"

    Write-Host -NoNewline "Expanding..."
    Expand-Archive -Path $NAME".zip" -Force
    Remove-Item -Path $NAME".zip" -Force
    Write-Host "Done."
}

$storageUrl = "https://codeproject-ai.s3.ca-central-1.amazonaws.com/sense/installer/"

if (-Not (Test-Path -Path "venv")) {
    DownloadAndExtract -URL $storageUrl"python-venv.zip"          -NAME "venv"
}

if (-Not (Test-Path -Path "redis")) {
    DownloadAndExtract -URL $storageUrl"redis.zip"                -NAME "redis"
}

if (-Not (Test-Path -Path "models")) {
    DownloadAndExtract -URL $storageUrl"models.zip"               -NAME "models"
}

<#
if (-Not (Test-Path -Path "windows_packages_cpu")) 
    DownloadAndExtract -URL $storageUrl"windows_packages_cpu.zip" -NAME "windows_packages_cpu"
}
if (-Not (Test-Path -Path "windows_packages_gpu")) {
    DownloadAndExtract -URL $storageUrl"windows_packages_gpu.zip" -NAME "windows_packages_gpu"
}
if (-Not (Test-Path -Path "windows_setup")) {
    DownloadAndExtract -URL $storageUrl"windows_setup.zip" `      -NAME "windows_setup"
#>