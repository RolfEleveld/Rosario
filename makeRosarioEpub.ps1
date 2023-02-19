..\Scripts\ebook-Functions.ps1


## Variables
# sequence of texts
$sequence = [string[]]@()
$startSequence = [string[]]@('Señal de la santa cruz', 'Oración al Espíritu Santo', 'Credo', 'Padrenuestro', 'Ave Maria', 'Ave Maria', 'Ave Maria', 'Gloria')
$mysterioSequence = [string[]]@('Mysterio', 'Padre Nuestro', 'Ave Maria', 'Ave Maria', 'Ave Maria', 'Ave Maria', 'Ave Maria', 'Ave Maria', 'Ave Maria', 'Ave Maria', 'Ave Maria', 'Ave Maria', 'Gloria', 'Jaculatoria')
$endSequence = [string[]]@('Letanías de la virgen', 'Concluídos los Misterios', 'Divina Providencia', 'Ángel de la Guarda', 'Oración de San Miguel Arcángel', 'Bajo tu amparo', 'Oración de Santa Gertrudis la Grande', 'San Jose')

$weekDays = [PSObject[]]@(
  [PSCustomObject]@{Day = 'Lunes'; Misterio = 'Gozoso' },
  [PSCustomObject]@{Day = 'Martes'; Misterio = 'Doloroso' },
  [PSCustomObject]@{Day = 'Miercoles'; Misterio = 'Glorioso' },
  [PSCustomObject]@{Day = 'Jueves'; Misterio = 'Luminoso' },
  [PSCustomObject]@{Day = 'Viernes'; Misterio = 'Doloroso' },
  [PSCustomObject]@{Day = 'Sabado'; Misterio = 'Gozoso' },
  [PSCustomObject]@{Day = 'Domingo'; Misterio = 'Glorioso' }
)
$sequenceInstances = [int[]]@(1, 2, 3, 4, 5)

$sequence += $startSequence
$sequence += 'Dia' # choose the day
foreach ($day in $weekDays) {
  $sequence += "Dia-{0}" -f $day.Day # placeholder for naming as target from starting sequence
  foreach ($i in $sequenceInstances) {
    $sequence += $mysterioSequence | ForEach-Object -Process { if ($_ -match 'Mysterio') { "Mysterio-{0}-{1}" -f $day.Misterio, $i } else { $_ } }
  }
  $sequence += 'Fin' # placeholder for clicking to close on each day sequence
}
$sequence += $endSequence
# full sequence
$sequence -join ' - '


# Content Collection
[PSObject[]]$Collection = @() # files

$Collection += [PSCustomObject]@{id = "main"; nav = ""; href = "./main.xhtml"; mediatype = "application/xhtml+xml" }
$Collection += [PSCustomObject]@{id = "nav"; nav = ""; href = "./nav.xhtml"; properties = "nav"; mediatype = "application/xhtml+xml" }

# loop through all segments
$index = [int]0
foreach ($section in $sequence) {  
  # choose what to do with each element.
  $id = "rosario-{0:d3}" -f $index
  switch ($section) {
    # should be a know word
    'Señal de la santa cruz' { 
      $Collection += [PSCustomObject]@{id = $id ; name = "Senal de la santa cruz"; href = "./Resos/Senal-de-la-santa-cruz.xhtml"; mediatype = "application/xhtml+xml" }
    }
    'Credo' { 
      $Collection += [PSCustomObject]@{id = $id; name = "Credo"; href = "./Resos/Credo.xhtml"; mediatype = "application/xhtml+xml" }
    }
    'Padre Nuestro' { 
      $Collection += [PSCustomObject]@{id = $id; name = "Padre Nuestro"; href = "./Resos/Padre-Nuestro.xhtml"; mediatype = "application/xhtml+xml" }
    }
    'Ave Maria' { 
      $Collection += [PSCustomObject]@{id = $id; name = "Ave maria"; href = "./Resos/Avemaria.xhtml"; mediatype = "application/xhtml+xml" }
    }
    'Gloria' { 
      $Collection += [PSCustomObject]@{id = $id; name = "Gloria"; href = "./Resos/Gloria.xhtml"; mediatype = "application/xhtml+xml" }
    }
    'Jaculatoria' { 
      $Collection += [PSCustomObject]@{id = $id; name = "Jaculatoria"; href = "./Resos/Jaculatoria.xhtml"; mediatype = "application/xhtml+xml" }
    }
    'Letanías de la virgen' {
      $Collection += [PSCustomObject]@{id = $id; name = "Jaculatoria"; href = "./Resos/Jaculatoria.xhtml"; mediatype = "application/xhtml+xml" }
    }
    Default { 
      # what to do if an unknown word appears... Mysterios, days, etc.
      if ($section -match 'Mysterio') {
         $Collection += [PSCustomObject]@{id = $id; name = $section -replace '-', ' '; href = "./Resos/{0}.xhtml" -f $section; mediatype = "application/xhtml+xml" }
      } elseif ($section -match 'Dia') {
        $Collection += [PSCustomObject]@{id = $id; name = $section -replace '-', ' '; href = "./Resos/{0}.xhtml" -f $section; mediatype = "application/xhtml+xml" }
      }
    }
  }
  $index++
}
$Collection | Format-List

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

# ideal Structure to create
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

# Create the navigation

$groups = $htmlSet | Group-Object -Property "nav"
$segments = $groups | ForEach-Object { $entries = $_.Group | ForEach-Object { "<li><a href=""$($_.href)"">$($_.name)</a></li>" } -join ""; "<li><span>$($_.nav)</span><ol>$entries</ol></li>" }
# replace @Entries@ below with the set of menu entries for @Group@
"<li><span>@Group@</span><ol>@Entries@</ol></li>"
# replace @Segments@ below with the collection of menu segments
"<html xmlns=""http://www.w3.org/1999/xhtml"" xmlns:epub=""http://www.idpf.org/2007/ops""><head><title>Rosario</title></head><body><nav epub:type=""list-type""><h1>Rosario</h1><ol>@Segments@</ol></nav></body></html>"

# Create the epub


# compress the content of the temp folder into a .epub
$allContent = Get-ChildItem -Path . -Recurse | Where-Object -Property Name -NotIn -Value @('makeRosarioEpub.ps1', 'Rosario.epub', '.vscode', '.gitignore', '.git') | Where-Object -Property FullName -NotMatch '\\.git\\' | Where-Object -Property FullName -NotMatch '\\.vscode\\'
$compoundName = "Rosario"
if (-not(@("", $null) -contains $Author)) {
  $compoundName += ' - ' + $Author
}
$compoundName += '.epub'
$epubFileName = $compoundName
$allContent | Compress-Archive -DestinationPath $epubFileName -CompressionLevel Optimal -Force
              
# open the .epub file created
start $epubFileName
