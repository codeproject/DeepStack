function Download($URL, $NAME){
    # Write-Host -NoNewline "Downloading" $NAME "..."
    # (New-Object System.Net.WebClient).DownloadFile($URL, $NAME+".zip")

    DownloadFile $URL $NAME".zip"

    Write-Host -NoNewline "Expanding..."
    Expand-Archive -Path $NAME".zip" -Force
    Remove-Item -Path $NAME".zip" -Force
    Write-Host "Done."
}

function DownloadFile($url, $targetFile)
{
   $uri = New-Object "System.Uri" $url
   Write-Host $uri
   
   $request = [System.Net.HttpWebRequest]::Create($uri)
   $request.set_Timeout(15000) #15 second timeout

   $response = $request.GetResponse()
   $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)

   $responseStream = $response.GetResponseStream()
   $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $targetFile, Create

   $buffer = new-object byte[] 10KB
   $count = $responseStream.Read($buffer,0,$buffer.length)
   $downloadedBytes = $count

   while ($count -gt 0)
   {
       $targetStream.Write($buffer, 0, $count)
       $count = $responseStream.Read($buffer,0,$buffer.length)
       $downloadedBytes = $downloadedBytes + $count

       Write-Progress -activity "Downloading file '$($url.split('/') | Select -Last 1)'" -status "Downloaded ($([System.Math]::Floor($downloadedBytes/1024))K of $($totalLength)K): " -PercentComplete ((([System.Math]::Floor($downloadedBytes/1024)) / $totalLength)  * 100)
   }

   Write-Progress -activity "Finished downloading file '$($url.split('/') | Select -Last 1)'"

   $targetStream.Flush()
   $targetStream.Close()
   $targetStream.Dispose()
   $responseStream.Dispose()
}

Download -URL "https://www.codeproject.com/ai/sense/installer/models.zip" -NAME "models"
Download -URL "https://www.codeproject.com/ai/sense/installer/python-venv.zip" -NAME "python-venv"
Download -URL "https://www.codeproject.com/ai/sense/installer/redis.zip" -NAME "redis"
Download -URL "https://www.codeproject.com/ai/sense/installer/windows_packages_cpu.zip" -NAME "windows_packages_cpu"
# Download -URL "https://www.codeproject.com/ai/sense/installer/windows_packages_gpu.zip" -NAME "windows_packages_gpu"
# Download -URL "https://www.codeproject.com/ai/sense/installer/windows_setup.zip" -NAME "windows_setup"
