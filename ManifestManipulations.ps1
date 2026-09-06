# The below needs to be done in a silent non-interactive manner
if (-not (Get-Command -Module ImportExcel -ErrorAction SilentlyContinue)) {
  Install-Module -Name ImportExcel -Scope CurrentUser -Force -AllowClobber
  Import-Module ImportExcel
}

# Export the manifest items from content.opf to a CSV file
function Export-ManifestToCsv {
  # Load Manifest from Content.opf
  [xml]$a = Get-Content .\content.opf
  $ns = New-Object System.Xml.XmlNamespaceManager($a.NameTable)
  $ns.AddNamespace("opf", "http://www.idpf.org/2007/opf")
  # Select all manifest items
  $items = $a.SelectNodes("//opf:manifest/opf:item", $ns)
  # Write this out to a CSV file
  $items | ConvertTo-Csv -Delimiter ";" | Out-File -FilePath ./Manifest.csv -Encoding utf8 -Force
  # The File gets manipulated as XLSX which loads the CSV File.
}

# The File gets manipulated as XLSX which loads the CSV File.

function Update-ManifestFromXlsx {
  # Update the Manifest segment based on the manipulated XLSX file
  # Load the Lines from the manipulated XLSX file, Table name Manifest
  $lines = Import-Excel -Path ./Manifest.xlsx -WorksheetName "Manifest"

  [xml]$opf = Get-Content .\content.opf

  # Namespace manager
  $ns = New-Object System.Xml.XmlNamespaceManager($opf.NameTable)
  $ns.AddNamespace("opf", "http://www.idpf.org/2007/opf")

  # Find manifest node
  $manifest = $opf.SelectSingleNode("//opf:manifest", $ns)
  # Remove all existing entries
  $manifest.RemoveAll()

  # Find teh spine
  $spine = $opf.SelectSingleNode("//opf:spine", $ns)
  # Remove all <itemref> children
  $spine.RemoveAll()

  # run through the lines and create the manifest entry
  # and if it is an xhtml page create the spine entry in the sequence of $lines
  foreach ($line in $lines) {
    $newItem = $opf.CreateElement("item", "http://www.idpf.org/2007/opf")
    $newItem.SetAttribute("id", $line.id)
    $newItem.SetAttribute("href", $line.href)
    $newItem.SetAttribute("media-type", $line.'media-type')
    $manifest.AppendChild($newItem) > $null

    if ($line.'media-type' -eq "application/xhtml+xml") {
      $newItemRef = $opf.CreateElement("itemref", "http://www.idpf.org/2007/opf")
      $newItemRef.SetAttribute("idref", $line.id)
      $spine.AppendChild($newItemRef) > $null
    }
    if ($line."media-type" -match "x-dtbncx\+xml") {
      Write-host "Setting spine toc attribute to $($line.id)" -ForegroundColor Green
      $spine.SetAttribute("toc", $line.id)
    }
  }
  # Save the updated content.opf
  $opf.Save(".\content.opf")
}
