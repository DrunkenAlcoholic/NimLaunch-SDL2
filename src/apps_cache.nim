## apps_cache.nim — application discovery and cache management.

import std/[os, json, tables, sequtils, times, options, strutils, algorithm]
import ./[state, parser, paths]

const CacheFormatVersion = 5

proc desktopDirFingerprint(dir: string): tuple[newest: int64; signature: string] =
  ## Build a lightweight fingerprint for *.desktop files under *dir*.
  ## Includes newest mtime, file count, summed mtimes, and summed file sizes.
  if not dirExists(dir):
    return (0'i64, "0:0:0:0")
  var newest = 0'i64
  var count = 0'i64
  var sumMtime = 0'i64
  var sumSize = 0'i64
  for entry in walkDirRec(dir, yieldFilter = {pcFile}):
    if entry.endsWith(".desktop"):
      try:
        let info = getFileInfo(entry)
        let m = times.toUnix(info.lastWriteTime)
        if m > newest: newest = m
        inc count
        sumMtime += m
        sumSize += info.size.int64
      except CatchableError:
        discard
  (newest, $count & ":" & $newest & ":" & $sumMtime & ":" & $sumSize)

proc loadApplications*() =
  ## Scan .desktop files with caching to ~/.cache/nimlaunch/apps.json.
  let appDirs = applicationDirs()
  var dirMtimes: seq[int64] = @[]
  var dirSignatures: seq[string] = @[]
  for dir in appDirs:
    let fp = desktopDirFingerprint(dir)
    dirMtimes.add fp.newest
    dirSignatures.add fp.signature

  let cacheBase = cacheDir()
  let cacheFile = cacheBase / "apps.json"

  if fileExists(cacheFile):
    try:
      let node = parseJson(readFile(cacheFile))
      if node.kind == JObject and node.hasKey("formatVersion"):
        let c = to(node, CacheData)
        if c.formatVersion == CacheFormatVersion and
           c.appDirs == appDirs and c.dirMtimes == dirMtimes and
           c.dirSignatures == dirSignatures:
          allApps = c.apps
          filteredApps = @[]
          matchSpans = @[]
          return
      else:
        echo "Cache invalid — rescanning …"
    except CatchableError as e:
      echo "Cache miss — rescanning (", e.name, ": ", e.msg, ")"

  var dedup = initTable[string, DesktopApp]()
  for dir in appDirs:
    if not dirExists(dir): continue
    for path in walkDirRec(dir, yieldFilter = {pcFile}):
      if not path.endsWith(".desktop"): continue
      let opt = parseDesktopFile(path)
      if isSome(opt):
        let app = get(opt)
        let sanitizedExec = parser.stripFieldCodes(app.exec).strip()
        var key = sanitizedExec.toLowerAscii
        if key.len == 0:
          key = getBaseExec(app.exec).toLowerAscii
        if key.len == 0:
          key = app.name.toLowerAscii
        if not dedup.hasKey(key) or (app.hasIcon and not dedup[key].hasIcon):
          dedup[key] = app

  allApps = dedup.values.toSeq
  allApps.sort(proc(a, b: DesktopApp): int = cmpIgnoreCase(a.name, b.name))
  filteredApps = @[]
  matchSpans = @[]
  try:
    createDir(cacheBase)
    writeFile(cacheFile, pretty(%CacheData(formatVersion: CacheFormatVersion,
                                           appDirs: appDirs,
                                           dirMtimes: dirMtimes,
                                           dirSignatures: dirSignatures,
                                           apps: allApps)))
  except CatchableError:
    echo "Warning: cache not saved."
