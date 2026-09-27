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

local function trim(text)
    checkString(text, "trim::text")
    -- Wrapped in parens to force a single return value (gsub also returns a match count)
    return (text:gsub("^%s*(.-)%s*$", "%1"))
end

local function normalizePath(filePath)
    checkString(filePath, "normalizePath::filePath")
    return path.translate(filePath):gsub("\\", "/")
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

-- Recursively creates dirPath and any missing parent directories
local function ensureDirectory(dirPath)
    if dirPath == nil or dirPath == "" or dirPath == "." then
        return
    end

    if not os.isdir(dirPath) then
        ensureDirectory(path.getdirectory(dirPath))
        if not os.isdir(dirPath) then
            local ok, err = os.mkdir(dirPath)
            if not ok then
                error("Failed to create directory '" .. dirPath .. "': " .. (err or "unknown error"))
            end
        end
    end
end

-- Runs a shell command
-- quiet: when true, redirects stdout/stderr and skips echoing the command
local function executeCommand(command, quiet)
    checkString(command, "executeCommand::command")

    local fullCommand = command
    if quiet then
        local redirectOutput = (os.host() == "windows")
            and "> nul 2>&1"
            or "> /dev/null 2>&1"
        fullCommand = string.format("%s %s", command, redirectOutput)
    else
        print(command)
    end

    local ok = os.execute(fullCommand)

    -- This is a Lua-version distinction, not an OS distinction
    if type(ok) == "number" then
        return ok == 0
    end
    return ok == true
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

    return executeCommand(command, true)
end

-- Runs a version-check command, extracts the version with pattern, and reports it
local function checkToolVersion(command, pattern, toolName, notFoundMsg)
    checkString(command, "checkToolVersion::command")
    checkString(pattern, "checkToolVersion::pattern")
    checkString(toolName, "checkToolVersion::toolName")

    local output = readCommand(command)
    local version = output:match(pattern)

    if version == nil or version == "" then
        error(notFoundMsg or (toolName .. " not found"))
    else
        print(toolName .. " version " .. version .. " found")
    end
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
        ensureDirectory(path.getdirectory(target))
        print("Creating file: '" .. target .. "'")
        local file = io.open(target, "w")
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

-- Removes files under basePath matching any of the given wildcard patterns
-- basePath may itself contain a `**` component for a recursive search, e.g. "build/**"
-- patterns are filename wildcards, e.g. { "*.obj", "*.pdb" }
function Utils.removeFiles(basePath, patterns)
    checkString(basePath, "Utils.removeFiles::basePath")
    checkTable(patterns, "Utils.removeFiles::patterns")

    local normalizedBase = normalizePath(basePath)

    for _, pattern in ipairs(patterns) do
        checkString(pattern, "Utils.removeFiles::patterns[]")
        local mask = path.join(normalizedBase, pattern)

        for _, file in ipairs(os.matchfiles(mask)) do
            local ok, err = os.remove(file)
            if not ok then
                print("Failed to remove file: '" .. file .. "', " .. (err or "please remove it manually"))
            else
                print("Removed file: '" .. file .. "'")
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
    checkToolVersion(
        "cmake --version",
        "cmake version ([%d%.]+)",
        "CMake",
        "CMake not found, please install CMake before building"
    )
end

function Utils.checkGit()
    checkToolVersion(
        "git --version",
        "git version ([%w%.%-]+)",
        "Git",
        "Git not found, please install git before building"
    )
end

function Utils.checkClang()
    if os.host() == "windows" then
        return
    end

    checkToolVersion(
        "clang --version 2>/dev/null",
        "clang version ([%d%.]+)",
        "Clang",
        "Clang not found, please install clang before building"
    )
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

-- Configures (if not already configured) and builds a CMake project.
function Utils.buildWithCMake(projectDir, buildDir, config)
    checkString(projectDir, "Utils.buildWithCMake::projectDir")
    checkString(buildDir, "Utils.buildWithCMake::buildDir")
    checkString(config, "Utils.buildWithCMake::config")

    local projectDirectory = normalizePath(projectDir)
    local buildDirectory = normalizePath(buildDir)
    local cmakeCache = path.join(buildDirectory, "CMakeCache.txt")

    if fileExists(cmakeCache) then
        print("Project already configured: '" .. projectDirectory .. "', skipping configure...")
    else
        if os.isdir(buildDirectory) then
            Utils.removeDirectory(buildDirectory) -- Clear out a partial/failed previous attempt
        end

        local configCmd = string.format('cmake -S "%s" -B "%s"', projectDirectory, buildDirectory)
        if not executeCommand(configCmd) then
            Utils.removeDirectory(buildDirectory)
            error("Failed to configure project with CMake at: '".. projectDirectory .. "'")
        end
    end

    local buildCmd = string.format('cmake --build "%s" --config "%s"', buildDirectory, config)
    if not executeCommand(buildCmd) then
        error("Failed to build project with CMake at: '".. projectDirectory .. "'")
    end
end

-- Downloads a git repo into targetDir if it is not already present.
-- cloneAndCheckout(targetDirectory) must perform the actual clone/checkout and
-- return true on success, or false plus an error message on failure.
local function fetchRepo(targetDir, repoUrl, cloneAndCheckout)
    checkString(targetDir, "fetchRepo::targetDir")
    checkString(repoUrl, "fetchRepo::repoUrl")

    local targetDirectory = normalizePath(targetDir)
    if os.isdir(targetDirectory) then
        print("Repo: '" .. repoUrl .. "' already installed, skipping")
        return
    end

    print("Downloading repo: '" .. repoUrl .. "'")

    local ok, errMsg = cloneAndCheckout(targetDirectory)
    if not ok then
        Utils.removeDirectory(targetDirectory)
        error(errMsg)
    end

    print("Repo '" .. repoUrl .. "' downloaded successfully")
end

-- Downloads a Git dependency by branch name if it's missing
-- Example: Utils.fetchRepoByBranch(Global.depDir .. "/Cpptrace", "https://github.com/jeremy-rifkin/cpptrace.git", "master")
function Utils.fetchRepoByBranch(targetDir, repoUrl, branch)
    checkString(branch, "Utils.fetchRepoByBranch::branch")

    fetchRepo(targetDir, repoUrl, function(targetDirectory)
        local command = string.format(
            'git -c advice.detachedHead=false clone --branch "%s" --verbose "%s" "%s"',
            branch, repoUrl, targetDirectory
        )
        if not executeCommand(command) then
            return false, "Failed to download '" .. repoUrl .. "'"
        end
        return true
    end)
end

-- Downloads a Git dependency by tag if it's missing
-- Example: Utils.fetchRepoByTag(Global.depDir .. "/Cpptrace", "https://github.com/jeremy-rifkin/cpptrace.git", "v0.6.3")
function Utils.fetchRepoByTag(targetDir, repoUrl, tag)
    checkString(tag, "Utils.fetchRepoByTag::tag")

    fetchRepo(targetDir, repoUrl, function(targetDirectory)
        local command = string.format(
            'git -c advice.detachedHead=false clone --branch "%s" --single-branch --verbose "%s" "%s"',
            tag, repoUrl, targetDirectory
        )
        if not executeCommand(command) then
            return false, "Failed to download '" .. repoUrl .. "'"
        end
        return true
    end)
end

-- Example: Utils.fetchRepoByRevision(Global.depDir .. "/Cpptrace", "https://github.com/jeremy-rifkin/cpptrace.git", "90de25f1dfe637b7929454644e39d0436606c999")
function Utils.fetchRepoByRevision(targetDir, repoUrl, revision)
    checkString(revision, "Utils.fetchRepoByRevision::revision")

    fetchRepo(targetDir, repoUrl, function(targetDirectory)
        local cloneCmd = string.format('git clone --verbose "%s" "%s"', repoUrl, targetDirectory)
        if not executeCommand(cloneCmd) then
            return false, "Failed to clone repo: '" .. repoUrl .. "'"
        end

        local fetchCmd = string.format('git -C "%s" fetch origin "%s"', targetDirectory, revision)
        if not executeCommand(fetchCmd) then
            return false, "Failed to fetch revision: '" .. revision .. "'"
        end

        local checkoutCmd = string.format('git -C "%s" -c advice.detachedHead=false checkout "%s"', targetDirectory, revision)
        if not executeCommand(checkoutCmd) then
            return false, "Failed to checkout revision: '" .. revision .. "'"
        end

        return true
    end)
end
