-----------------------------
-- Utilities
-- Not the most efficient, but it will do
-----------------------------

-----------------------------
-- Local
-----------------------------

local function checkString(parameter, name)
   assert(parameter ~= nil, name .. " cannot be nil")
   assert(type(parameter) == "string", name .. " must be a string, not type: " .. type(parameter))
   assert(#parameter > 0, name .. " cannot be empty")
end

local function checkTable(parameter, name)
   assert(parameter ~= nil, name .. " cannot be nil")
   assert(type(parameter) == "table", name .. " must be a table, not type: " .. type(parameter))
   assert(#parameter > 0, name .. " cannot be empty")
end

local function checkUnsignedInt(value, name)
   assert(type(value) == "number", (name or "value") .. " must be a number")
   assert(value % 1 == 0, (name or "value") .. " must be an integer")
   assert(value >= 0, (name or "value") .. " must be an unsigned integer (non-negative)")
end

local function trim(string)
   checkString(string, "trim::string")
   local trimmed = string:gsub("^%s*(.-)%s*$", "%1")
   local output = (trimmed == nil) and "" or trimmed
   return output
end

local function normalizePath(filePath)
   checkString(filePath, "normalizePath::filePath")
   return path.translate(filePath):gsub("\\", "/")
end

-- Function to check if a filename matches a pattern with *
local function matchesPattern(filename, pattern)
   checkString(filename, "matchesPattern::filename")
   checkString(pattern, "matchesPattern::pattern")

   -- Convert wildcard pattern to Lua pattern
   local luaPattern = pattern:gsub("([%.%+%-%^%$%(%)%%])", "%%%1"):gsub("%*", ".*")
   return filename:match("^" .. luaPattern .. "$") ~= nil
end

local function fileExists(filePath)
   checkString(filePath, "fileExists::filePath")
   local file = io.open(normalizePath(filePath), "r")
   if file then
      file:close()
      return true
   else
      return false
   end
end

local function executeCommand(command)
   checkString(command, "executeCommand::command")

   print(command)
   local result = os.execute(command)
   return (os.host() == "windows")
      and (result ~= nil and result)
      or (result == 0)
end

local function executeCommandQuiet(command)
   checkString(command, "executeCommandQuiet::command")

   local redirectOutput = (os.host() == "windows")
      and "> nul 2>&1"
      or "> /dev/null 2>&1"

   local fullCommand = string.format("%s %s", command, redirectOutput)
   local result = os.execute(fullCommand)
   return (os.host() == "windows")
      and (result ~= nil and result)
      or (result == 0)
end

local function readCommand(command)
   checkString(command, "readCommand::command")

   local redirectError = (os.host() == "windows")
      and "2> nul"
      or "2> /dev/null"

   local pipe = io.popen(string.format("%s %s", command, redirectError))
   if not pipe then
      return ""
   end

   local output = pipe:read("*a")
   pipe:close()

   if output == nil or output == "" then
      return ""
   else
      return trim(output)
   end
end

local function listFiles(directory)
   checkString(directory, "listFiles::directory")

   local command = (os.host() == "windows")
      and string.format('dir /b "%s"', normalizePath(directory))
      or string.format('ls "%s"', normalizePath(directory))

   local output = readCommand(command)
   local pattern = (os.host() == "windows") and "[^\r\n]+" or "[^\n]+"
   local files = {}
   for filename in output:gmatch(pattern) do
      table.insert(files, filename)
   end

   return files
end

local function listDirs(directory)
   checkString(directory, "listDirs::directory")

   local command = (os.host() == "windows")
      and string.format('dir /b /ad "%s"', normalizePath(directory))
      or string.format('find "%s" -mindepth 1 -maxdepth 1 -type d -printf "%%f\n"', normalizePath(directory))

   local output = readCommand(command)
   local pattern = (os.host() == "windows") and "[^\r\n]+" or "[^\n]+"
   local dirs = {}
   for dirname in output:gmatch(pattern) do
      table.insert(dirs, dirname)
   end
   return dirs
end

local function listFilesWithMaxDepth(directory, maxDepth)
   checkString(directory, "listFilesWithMaxDepth::directory")
   checkUnsignedInt(maxDepth, "listFilesWithMaxDepth::maxDepth")

   directory = normalizePath(directory)
   local files = {}

   -- Always include this level
   local levelFiles = listFiles(directory)
   for i, f in ipairs(levelFiles) do
      files[#files+1] = path.join(directory, f)
   end

   -- Recurse into subdirs if we still have depth left
   if maxDepth > 0 then
      local subdirs = listDirs(directory)
      for _, d in ipairs(subdirs) do
         local subFiles = listFilesWithMaxDepth(path.join(directory, d), maxDepth - 1)
         for _, f in ipairs(subFiles) do
            files[#files+1] = f
         end
      end
   end

   return files
end

local function listFilesRecursive(directory)
   checkString(directory, "listFilesRecursive::directory")

   directory = normalizePath(directory)
   local command = (os.host() == "windows")
      and string.format('dir /b /s "%s"', directory)
      or string.format('find "%s" -printf"', directory)

   local output = readCommand(command)
   local pattern = (os.host() == "windows") and "[^\r\n]+" or "[^\n]+"
   local files = {}
   for filename in output:gmatch(pattern) do
      filename = normalizePath(filename)
      table.insert(files, filename)
   end

   return files
end

local function forceRemove(targetPath)
   checkString(targetPath, "forceRemove::targetPath")

   local target = normalizePath(targetPath)
   local isDir = os.isdir(target)
   local isFile = os.isfile(target)

   if not (isDir or isFile) then
      error(string.format("Target is not file or directory: '%s'", target))
   end

   local command = ""
   if os.host() == "windows" then
      -- Just windows thing
      target = path.translate(target):gsub("/", "\\")
      command = (isDir)
         and string.format('rmdir /S /Q "%s"', target)
         or string.format('del /F /S /Q /A "%s"', target)
   else
      command = string.format("rm -rf '%s'", target)
   end

   return executeCommandQuiet(command)
end

-----------------------------
-- Global
-----------------------------

Utils = {} -- Contains helpers

-----------------------------
-- Filesystem
-----------------------------

function Utils.normalizePath(filePath)
   return normalizePath(filePath)
end

function Utils.fileExists(filePath)
   return fileExists(filePath)
end

function Utils.createFile(filePath, dataToWrite)
   checkString(filePath, "Utils.createFile::filePath")

   local target = normalizePath(filePath)

   if not os.isfile(target) then
      print("Creating file: '" .. target .. "'")
      local file = io.open(filePath, "w")
      if file then
         if dataToWrite then
            file:write(dataToWrite)
         end
         file:close()
      else
         error("Failed to create '" .. target .. "'")
      end
   end
end

-- General function to remove files matching a * pattern in a directory and its subdirectories
function Utils.removeFiles(pathPattern, patterns)
   checkString(pathPattern, "Utils.removeFiles::pathPattern")
   checkTable(patterns, "Utils.removeFiles::patterns")

   -- Note: Relying on that path is using / as separator
   local filePath = normalizePath(pathPattern)

   local depth = 0
   for _ in filePath:gmatch("/%*") do
      depth = depth + 1
   end

   local isRecursive = filePath:find("/%*%*") ~= nil
   local baseDir = filePath:gsub("/%*%*", ""):gsub("/%*", "")

   -- Fallback to current directory
   if baseDir == "" then
      baseDir = "."
   end

   local files = (isRecursive)
      and listFilesRecursive(baseDir)
      or listFilesWithMaxDepth(baseDir, depth)

   for _, file in ipairs(files) do
      for _, pattern in ipairs(patterns) do
         if matchesPattern(file, pattern) then
            if not forceRemove(file) then
               print("Failed to remove file: '" .. file .. "', please remove it manually")
            else
               print("Removed file: '" .. file .. "'")
            end
         end
      end
   end
end

-- General function to remove a directory
function Utils.removeDirectory(directory)
   checkString(directory, "Utils.removeFiles::directory")

   local target = normalizePath(directory)
   if not os.isdir(target) then
      print("Cannot remove directory as directory does not exist or is not directory: '" .. target .. "'")
      return
   end

   if not forceRemove(target) then
      print("Failed to remove directory: '" .. target.. "' please remove it manually")
   else
      print("Directory removed: '" .. target .. "'")
   end
end

-----------------------------
-- Prerequisites
-----------------------------

function Utils.checkCMake()
   local command = "cmake --version"
   local output = readCommand(command)
   local version = output:match("cmake version ([%d%.]+)")
   if version == nil or version == "" then
      error("CMake not found, please install CMake before building")
   else
      print("CMake version " .. version .. " found")
   end
end

function Utils.checkGit()
   local command = "git --version"
   local output = readCommand(command)
   local version = output:match("git version ([%w%.%-]+)")
   if version == nil or version == "" then
      error("Git not found, please install git before building")
   else
      print("Git version " .. version .. " found")
   end
end

function Utils.checkClang()
   if os.host() == "windows" then
      return
   end

   local output = readCommand("clang --version 2>/dev/null")
   local version = output:match("clang version ([%d%.]+)")
   if version == nil or version == "" then
      error("Clang not found, please install clang before building")
   else
      print("Clang version " .. version .. " found")
   end
end

function Utils.checkVisualStudio()
   if os.host() ~= "windows" then
      print("Not using windows, skipping Visual Studio check")
      return
   end

   local programFiles = os.getenv("ProgramFiles(x86)") or os.getenv("ProgramFiles")
   if not programFiles then
      error("Cannot access Program Files directory")
   end

   local vsWhere = path.join(programFiles, "Microsoft Visual Studio/Installer/vswhere.exe")
   if not fileExists(vsWhere) then
      error("vswhere.exe not found, cannot verify Visual Studio installation")
   end

   local query = string.format('"%s" -version [17.0,) -property installationVersion', vsWhere)
   local output = readCommand(query)
   if output == "" then
      error("Visual Studio 2022 or newer not found")
   end

   -- Capture only the numeric version (e.g.: 17.9.34622.214)
   local version = output:match("([%d%.]+)")
   if version == nil or version == "" then
      error("Visual Studio 2022 or newer not found")
   else
      print("Visual Studio version " .. version .. " found")
   end
end

-----------------------------
-- Handle Dependencies
-----------------------------

function Utils.buildWithCMake(projectDir, buildDir, config)
   checkString(projectDir, "Utils.buildWithCMake::projectDir")
   checkString(buildDir, "Utils.buildWithCMake::buildDir")
   checkString(config, "Utils.buildWithCMake::config")

   local projectDirectory = normalizePath(projectDir)
   local buildDirectory = normalizePath(buildDir)

   if os.isdir(buildDirectory) then
      print("Project already build: '" .. projectDirectory .. "', skipping...")
      return
   end

   local configCmd = string.format('cmake -S "%s" -B "%s"', projectDirectory, buildDirectory)
   if not executeCommand(configCmd) then
      Utils.removeDirectory(buildDirectory)
      error("Failed to configure project with CMake at: '".. projectDirectory .. "'")
   end

   local buildCmd = string.format('cmake --build "%s" --config %s', buildDirectory, config)
   if not executeCommand(buildCmd) then
      Utils.removeDirectory(buildDirectory)
      error("Failed to build project with CMake at: '".. projectDirectory .. "'")
   end
end

-- Downloads a Git dependency by branch name if it's missing
-- Example: Utils.fetchRepoByBranch(Global.depDir .. "/Cpptrace", "https://github.com/jeremy-rifkin/cpptrace.git", "master")
function Utils.fetchRepoByBranch(targetDir, repoUrl, branch)
   checkString(targetDir, "Utils.fetchRepoByBranch::targetDir")
   checkString(repoUrl, "Utils.fetchRepoByBranch::repoUrl")
   checkString(branch, "Utils.fetchRepoByBranch::branch")

   local targetDirectory = normalizePath(targetDir)

   if not os.isdir(targetDirectory) then
      local command = string.format(
         'git -c advice.detachedHead=false clone --branch %s --verbose "%s" "%s"',
         branch, repoUrl, targetDirectory
      )

      print("Downloading repo: '" .. repoUrl .. "'")

      if not executeCommand(command) then
         Utils.removeDirectory(targetDirectory)
         error("Failed to download '" .. repoUrl .. "'")
      end

      print("Repo '" .. repoUrl .. "' downloaded successfully")
   else
      print("Repo: '" .. repoUrl .. "' already installed, skipping")
   end
end

-- Downloads a Git dependency by tag if it's missing
-- Example: Utils.fetchRepoByTag(Global.depDir .. "/Cpptrace", "https://github.com/jeremy-rifkin/cpptrace.git", "v0.6.3")
function Utils.fetchRepoByTag(targetDir, repoUrl, tag)
   checkString(targetDir, "Utils.fetchRepoByTag::targetDir")
   checkString(repoUrl, "Utils.fetchRepoByTag::repoUrl")
   checkString(tag, "Utils.fetchRepoByTag::tag")

   local targetDirectory = normalizePath(targetDir)

   if os.isdir(targetDirectory) then
      print("Repo: '" .. repoUrl .. "' already installed, skipping")
      return
   end

   print("Downloading repo: '" .. repoUrl .. "'")
   local command = string.format(
      'git -c advice.detachedHead=false clone --branch %s --single-branch --verbose "%s" "%s"',
      tag, repoUrl, targetDirectory
   )

   if not executeCommand(command) then
      Utils.removeDirectory(targetDirectory)
      error("Failed to download '" .. repoUrl .. "'")
   end

   print("Repo '" .. repoUrl .. "' downloaded successfully")
end

-- Example: Utils.fetchRepoByRevision(Global.depDir .. "/Cpptrace", "https://github.com/jeremy-rifkin/cpptrace.git", "90de25f1dfe637b7929454644e39d0436606c999")
function Utils.fetchRepoByRevision(targetDir, repoUrl, revision)
   checkString(targetDir, "Utils.fetchRepoByRevision::targetDir")
   checkString(repoUrl, "Utils.fetchRepoByRevision::repoUrl")
   checkString(revision, "Utils.fetchRepoByRevision::revision")

   local targetDirectory = normalizePath(targetDir)

   if not os.isdir(targetDirectory) then
      print("Cloning repo: '" .. repoUrl .. "'")

      local cloneCmd = string.format('git clone --verbose "%s" "%s"', repoUrl, targetDirectory)
      if not executeCommand(cloneCmd) then
         Utils.removeDirectory(targetDirectory)
         error("Failed to clone repo: '" .. repoUrl .. "'")
      end

      local fetchCmd = string.format('git -C "%s" fetch origin %s', targetDirectory, revision)
      if not executeCommand(fetchCmd) then
         Utils.removeDirectory(targetDirectory)
         error("Failed to fetch revision: '" .. revision .. "'")
      end

      local checkoutCmd = string.format('git -C "%s" -c advice.detachedHead=false checkout %s', targetDirectory, revision)
      if not executeCommand(checkoutCmd) then
         Utils.removeDirectory(targetDirectory)
         error("Failed to checkout revision: '" .. revision .. "'")
      end

      print("Repo '" .. repoUrl .. "' checked out at revision: '" .. revision .. "'")
   else
      print("Repo: '" .. repoUrl .. "' already installed, skipping")
   end
end
