..\Scripts\ebook-Functions.ps1

## Variables
[PSObject[]]$Collection = @() # files

$Collection += [PSObject]@{id = "main"; href = "./main.xhtml"; mediatype = "application/xhtml+xml" }
$Collection += [PSObject]@{id = "nav"; href = "./nav.xhtml"; properties = "nav"; mediatype = "application/xhtml+xml" }
$Collection += [PSObject]@{id = "domingo-00"; href = "./Resos/Senal-de-la-santa-cruz.xhtml"; mediatype = "application/xhtml+xml" }
$Collection += [PSObject]@{id = "domingo-01"; href = "./Resos/Credo.xhtml"; mediatype = "application/xhtml+xml" }
$Collection += [PSObject]@{id = "domingo-02"; href = "./Resos/Padre-Nuestro.xhtml"; mediatype = "application/xhtml+xml" }
$Collection += [PSObject]@{id = "domingo-03"; href = "./Resos/Avemaria.xhtml"; mediatype = "application/xhtml+xml" }
$Collection += [PSObject]@{id = "domingo-04"; href = "./Resos/Avemaria.xhtml"; mediatype = "application/xhtml+xml" }
$Collection += [PSObject]@{id = "domingo-05"; href = "./Resos/Avemaria.xhtml"; mediatype = "application/xhtml+xml" }
$Collection += [PSObject]@{id = "domingo-06"; href = "./Resos/Gloria.xhtml"; mediatype = "application/xhtml+xml" }
$Collection += [PSObject]@{id = "domingo-07"; href = "./Resos/Domingo-Misterio-1.xhtml"; mediatype = "application/xhtml+xml" }
$Collection += [PSObject]@{id = "domingo-08"; href = "./Resos/Padre-Nuestro.xhtml"; mediatype = "application/xhtml+xml" }
$Collection += [PSObject]@{id = "domingo-09"; href = "./Resos/Avemaria.xhtml"; mediatype = "application/xhtml+xml" }
$Collection += [PSObject]@{id = "domingo-10"; href = "./Resos/Avemaria.xhtml"; mediatype = "application/xhtml+xml" }
$Collection += [PSObject]@{id = "domingo-11"; href = "./Resos/Avemaria.xhtml"; mediatype = "application/xhtml+xml" }
$Collection += [PSObject]@{id = "domingo-12"; href = "./Resos/Avemaria.xhtml"; mediatype = "application/xhtml+xml" }
$Collection += [PSObject]@{id = "domingo-13"; href = "./Resos/Avemaria.xhtml"; mediatype = "application/xhtml+xml" }
$Collection += [PSObject]@{id = "domingo-14"; href = "./Resos/Avemaria.xhtml"; mediatype = "application/xhtml+xml" }
$Collection += [PSObject]@{id = "domingo-15"; href = "./Resos/Avemaria.xhtml"; mediatype = "application/xhtml+xml" }
$Collection += [PSObject]@{id = "domingo-16"; href = "./Resos/Avemaria.xhtml"; mediatype = "application/xhtml+xml" }
$Collection += [PSObject]@{id = "domingo-17"; href = "./Resos/Avemaria.xhtml"; mediatype = "application/xhtml+xml" }
$Collection += [PSObject]@{id = "domingo-18"; href = "./Resos/Avemaria.xhtml"; mediatype = "application/xhtml+xml" }
$Collection += [PSObject]@{id = "domingo-19"; href = "./Resos/Gloria.xhtml"; mediatype = "application/xhtml+xml" }
$Collection += [PSObject]@{id = "domingo-20"; href = "./Resos/Jaculatoria.xhtml"; mediatype = "application/xhtml+xml" }
$Collection += [PSObject]@{id = "domingo-21"; href = "./Resos/Domingo-Misterio-2.xhtml"; mediatype = "application/xhtml+xml" }

[String]$Destination = ".\" # Assuming current path
[string]$CoverFile = "" # Assuming no cover
[string]$Title = "" #Assuming no title
[string]$Author = ""
[datetime]$Date = [DateTime]::Now # assuming now
[string]$Language = "en" # assuming English

## Begin
# Spine segment of system
$spine = @()
$manifest = @()

# Structure to create
# /EPUB/content.opf
# /EPUB/css/stylesheet.css
# /EPUB/media/*.jpg
# /EPUB/xhtml/nav.html
# /EPUB/xhtml/*.html
# /META-INF
# mimetype

$mimetypeFilePath = "mimetype"
$mimetypeFileContent = 'application/epub+zip'
$mimetypeFileContent | Out-File -FilePath $mimetypeFilePath -Encoding utf8 -Force

$containerMetaPath = "META-INF"
New-Item -Path $containerMetaPath -ItemType Container -Force | Out-Null
$containerFilePath = Join-Path -Path $containerMetaPath -ChildPath "container.xml"
$containerFileContent = '<?xml version="1.0"?><container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container"><rootfiles><rootfile full-path="content.opf" media-type="application/oebps-package+xml"/></rootfiles></container>'
$containerFileContent | Out-File -FilePath $containerFilePath -Encoding utf8 -Force

$EpubCssFolderPath = "css"
New-Item -Path $EpubCssFolderPath -ItemType Container -Force | Out-Null

$EpubCssFilePath = Join-Path -Path $EpubCssFolderPath -ChildPath "stylesheet.css"
$EpubCssFileContent = 'body{display:block;font-size:1em;page-break-before:always;margin:0 5pt}h1{display:block;font-size:2em;font-weight:700;page-break-before:always;margin:.67em 0}p{display:block;font-size:1em;margin:0 5pt;padding:0}a{color:inherit;text-decoration:inherit;cursor:default}a[href]{text-decoration:underline;cursor:pointer}'
$EpubCssFileContent | Out-File -FilePath $EpubCssFilePath -Encoding utf8 -Force

# Filtering all passed in files to media types
$mediaSet = ($Collection | Where-Object -Property href -Match -Value ".*\.jpg$") + ($Collection | Where-Object -Property href -Match -Value ".*\.gif$") + ($Collection | Where-Object -Property href -Match -Value ".*\.mp4$")

$htmlSet = ($Collection | Where-Object -Property href -Match -Value ".*\.x?html$")
$spineSegment = $htmlSet | ForEach-Object { "<itemref idref=""$($_.id)""/>" }
# replace @Spine@ with <itemref idref="cha"/>

$mediaSet = ($Collection | Where-Object -Property Extension -NE -Value ".html")
$manifestHtmlSegment = $htmlSet | ForEach-Object { "<item href=""$($_.href)"" id=""$($_.id)"" media-type=""$($_.mediatype)""/>" }
$manifestMediaSegment = $mediaSet | ForEach-Object { "<item href=""$($_.href)"" id=""$($_.id)"" media-type=""$($_.mediatype)""/>" }
# replace @manifest@ with <item href="xhtml/epub30-changes.xhtml" id="cha" media-type="application/xhtml+xml"/>
# Adding Style Sheet to manifest
$manifestMediaSegment += '<item href="stylesheet.css" id="cover" media-type="text/css"/>'

# cover image
if ("" -ne $CoverFile) {
  $coverImageSource = Get-ChildItem -Path $CoverFile -File
  # Set the coverimage as an object
  $drawing = [Drawing.Image]::FromFile($coverImageSource.FullName)
  $coverHeight = $drawing.Height
  $coverWidth = $drawing.Width
  $drawing.Dispose()
  $coverImageName = $coverImageSource.Name
  $coverimageMimeType = switch ($coverImageSource.Extension) {
    ".png" { "image/png" }
    ".jpg" { "image/jpeg" }
    ".jpeg" { "image/jpeg" }
    ".gif" { "image/gif" }
    ".svg" { "image/svg+xml" }
  }

  # add cover page
  $coverPageContent = [System.Text.StringBuilder]'<?xml version="1.0" encoding="utf-8"?><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="' + $Language + '">'
  $coverPageContent.Append('<head><title>' + $Title + '</title><meta content="http://www.w3.org/1999/xhtml; charset=utf-8" http-equiv="Content-Type" /><link href="./stylesheet.css" type="text/css" rel="stylesheet" /></head>')
  $coverPageContent.Append('<body><svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="100%" height="100%" viewBox="0 0 ' + $coverWidth + ' ' + $coverHeight + '" preserveAspectRatio="xMidYMid meet"><image width="' + $coverWidth + '" height="' + $coverHeight + '" xlink:href="' + $coverImageName + '"/></svg></body>')
  $coverPageContent.Append('</html>')
  $coverPageFilePath = "coverpage.xhtml"
  $coverPageContent.ToString() | Out-File -FilePath $coverPageFilePath -Encoding utf8
  # add cover page to Manifest and spine
  $manifestMediaSegment += '<item href="' + $coverImageName + '" id="cover" media-type="' + $coverimageMimeType + '"/>'
  $manifestHtmlSegment += '<item href="coverpage.xhtml" id="cover" media-type="application/xhtml+xml"/>'
  $spineSegment += '<itemref idref="cover"/>'
}

$packageFileContent = '<?xml version="1.0" encoding="UTF-8"?><package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="uid"><metadata xmlns:dc="http://purl.org/dc/elements/1.1/"><dc:identifier id="uid">@ID@</dc:identifier><dc:title>@Title@</dc:title><dc:creator>@Creator@</dc:creator><dc:language>@Language@</dc:language><meta property="dcterms:modified">@Date@</meta></metadata><manifest><item href="xhtml/nav.html" id="nav" media-type="application/xhtml+xml"/><item href="css/stylesheet.css" media-type="text/css" id="css"/>@Manifest@</manifest><spine><itemref idref="nav" linear="no"/>@Spine@</spine></package>'

# replace @Title@ with $Title
$packageFileContent = $packageFileContent -replace "@Title@", $Title
# replace @Date@ with $Date
$packageFileContent = $packageFileContent -replace "@Date@", $Date.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
# replace @ID@ with New-Guid
$packageFileContent = $packageFileContent -replace "@ID@", (New-Guid)
# replace @Creator@ with $Author
$packageFileContent = $packageFileContent -replace "@Creator@", $Author
# replace @Language@ with $Language
$packageFileContent = $packageFileContent -replace "@Language@", $Language

$packageFileContent = $packageFileContent -replace "@Spine@", ($spineSegment -join '')
$packageFileContent = $packageFileContent -replace "@Manifest@", (($manifestHtmlSegment + $manifestMediaSegment) -join '')

# adding images to html as content
$opfContentFilePath = "content.opf"
$packageFileContent | Out-File -FilePath $opfContentFilePath -Encoding utf8 -Force
# Copy or move files into target situation

# Create the epub

# compress the content of the temp folder into a .epub
$allContent = Get-ChildItem -Path . -Recurse -Exclude 'makeRosarioEpub.ps1', 'Rosario.epub','.vscode'
$compoundName = "Rosario"
if (-not(@("", $null) -contains $Author)) {
  $compoundName += ' - ' + $Author
}
$compoundName += '.epub'
$epubFileName = $compoundName
$allContent | Compress-Archive -DestinationPath $epubFileName -CompressionLevel Optimal -Force
              
# Return the .epub file created
return $epubFileName
