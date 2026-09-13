# Convert BattleScribe 2.00 (legacy) constructs to 2.03 (modern) so New Recruit parses them.
#
#   characteristic : <characteristic name="N" characteristicTypeId="T" value="V"/>
#                 -> <characteristic name="N" typeId="T">V</characteristic>
#   cost           : costTypeId="X"      -> typeId="X"
#   profile        : profileTypeId="X"   -> typeId="X" (+ typeName="..." when absent)
#                    profileTypeName="N" -> typeName="N"
#
# Also bumps battleScribeVersion to 2.03, bumps each file's revision, and
# re-points every .cat's gameSystemRevision at the new .gst revision.
#
# Attribute values may legally contain ">", so tag matching is quote-aware.

$ErrorActionPreference = 'Stop'
$repo = 'C:\7th-Edition-Revised'
$files = Get-ChildItem "$repo\*" -Include *.cat,*.gst -File | Sort-Object Name

# ---- build profileTypeId -> name map across every file ----
$map = @{}
foreach ($f in $files) {
  $t = [IO.File]::ReadAllText($f.FullName)
  foreach ($m in [regex]::Matches($t, '<profileType\s(?:"[^"]*"|[^>"])*?>')) {
    $id = [regex]::Match($m.Value, '\sid="([^"]*)"').Groups[1].Value
    $nm = [regex]::Match($m.Value, '\sname="([^"]*)"').Groups[1].Value
    if ($id -and $nm) { $map[$id] = $nm }
  }
}
Write-Output "profileTypes known: $($map.Count)"

# ---- new game system revision (gst revision + 1) ----
$gstPath = Join-Path $repo 'Warhammer40K.gst'
$gstText = [IO.File]::ReadAllText($gstPath)
$newGsRev = [int][regex]::Match($gstText, '\srevision="(\d+)"').Groups[1].Value + 1
Write-Output "new gameSystem revision: $newGsRev"

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$totChar = 0; $totCost = 0; $totProf = 0; $skipped = 0
$nCharRef = [ref]0
$nProfRef = [ref]0

foreach ($f in $files) {
  $text = [IO.File]::ReadAllText($f.FullName)
  $orig = $text
  $nCost = 0

  # 1. characteristics -------------------------------------------------
  $text = [regex]::Replace($text, '<characteristic\b((?:"[^"]*"|[^>"])*?)\s*/>', {
    param($m)
    $attrs = $m.Groups[1].Value
    if ($attrs -notmatch 'characteristicTypeId=') { return $m.Value }

    # refuse anything carrying attributes we don't know how to carry over
    $names = @([regex]::Matches($attrs, '([A-Za-z]+)=') | ForEach-Object { $_.Groups[1].Value })
    foreach ($n in $names) {
      if ($n -notin @('name','characteristicTypeId','value')) {
        $script:skipped++
        return $m.Value
      }
    }

    $name = [regex]::Match($attrs, '\sname="([^"]*)"').Groups[1].Value
    $tid  = [regex]::Match($attrs, 'characteristicTypeId="([^"]*)"').Groups[1].Value
    $vm   = [regex]::Match($attrs, '\svalue="([^"]*)"')
    $script:nCharRef.Value++
    # the attribute value is already XML-escaped; escaped text is equally valid
    # as element content, so it carries over verbatim.
    if ($vm.Success -and $vm.Groups[1].Value.Length -gt 0) {
      return '<characteristic name="' + $name + '" typeId="' + $tid + '">' + $vm.Groups[1].Value + '</characteristic>'
    } else {
      return '<characteristic name="' + $name + '" typeId="' + $tid + '"/>'
    }
  })

  # 2. costs -----------------------------------------------------------
  $nCost = [regex]::Matches($text, 'costTypeId="').Count
  $text = $text -replace 'costTypeId="', 'typeId="'

  # 3. profiles --------------------------------------------------------
  $text = [regex]::Replace($text, '<profile\b((?:"[^"]*"|[^>"])*?)(/?)>', {
    param($m)
    $attrs = $m.Groups[1].Value
    $close = $m.Groups[2].Value
    if ($attrs -notmatch 'profileTypeId=') { return $m.Value }

    $new = $attrs -replace 'profileTypeName="', 'typeName="'
    $new = $new -replace 'profileTypeId="', 'typeId="'

    if ($new -notmatch '\stypeName="') {
      $tid = [regex]::Match($new, '\stypeId="([^"]*)"').Groups[1].Value
      if ($map.ContainsKey($tid)) {
        $tidAttr = [regex]::Match($new, '\stypeId="[^"]*"').Value
        $new = $new.Replace($tidAttr, $tidAttr + ' typeName="' + $map[$tid] + '"')
      }
    }
    $script:nProfRef.Value++
    return '<profile' + $new + $close + '>'
  })

  # 4. schema version --------------------------------------------------
  $text = $text -replace 'battleScribeVersion="2\.00"', 'battleScribeVersion="2.03"'

  # 5. bump this file's own revision (root element, first match only) ---
  $rx = [regex]'\srevision="(\d+)"'
  $text = $rx.Replace($text, { param($m) ' revision="' + ([int]$m.Groups[1].Value + 1) + '"' }, 1)

  # 6. re-point catalogues at the new game system revision --------------
  if ($f.Extension -eq '.cat') {
    $text = $text -replace 'gameSystemRevision="\d+"', ('gameSystemRevision="' + $newGsRev + '"')
  }

  if ($text -ne $orig) {
    [IO.File]::WriteAllText($f.FullName, $text, $utf8NoBom)
  }
  $totChar += $nCharRef.Value; $totCost += $nCost; $totProf += $nProfRef.Value
  Write-Output ("{0,-55} chars:{1,-6} costs:{2,-6} profiles:{3}" -f $f.Name, $nCharRef.Value, $nCost, $nProfRef.Value)
  $nCharRef.Value = 0; $nProfRef.Value = 0
}

Write-Output "=========================================="
Write-Output "characteristics converted: $totChar"
Write-Output "costs converted:           $totCost"
Write-Output "profiles converted:        $totProf"
Write-Output "skipped (unknown attrs):   $skipped"
