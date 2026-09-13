-----------------------------
-- Import
-----------------------------

include (path.translate("./Premake/Utils/Utils.lua")) -- Helpers

-----------------------------
-- Global
-----------------------------

Global = {}  -- Global data container
Link = {}    -- Used for linking other projects

-- Project name
Global.name = "Game Name"

-- Static directory paths
Global.rootDir = Utils.normalizePath(os.getcwd())
Global.gameDir = Utils.normalizePath(Global.rootDir .. "/Game")
Global.binDir = Utils.normalizePath(Global.rootDir .. "/Binaries")
Global.objDir = Utils.normalizePath(Global.rootDir .. "/Binaries/Intermediates")
Global.depDir = Utils.normalizePath(Global.rootDir .. "/Dependencies")

-- Paths with tokens to be expanded after project generation
Global.outProjectDir = Utils.normalizePath(path.join(Global.binDir, "%{cfg.system}-%{cfg.architecture}/%{cfg.buildcfg}/%{prj.name}"))
Global.libProjectDir = Utils.normalizePath(path.join(Global.binDir, "%{cfg.system}-%{cfg.architecture}/%{cfg.buildcfg}"))
Global.objProjectDir = Utils.normalizePath(path.join(Global.objDir, "%{cfg.system}-%{cfg.architecture}/%{cfg.buildcfg}/%{prj.name}"))

-----------------------------
-- Build
-----------------------------

print("Checking prerequisites...")
Utils.checkGit()
Utils.checkVisualStudio()

print("Cleaning previous setup...")
Utils.removeDirectory(Global.binDir)
Utils.removeFiles(Global.rootDir, {"*.sln", "*.vcxproj", "*.vcxproj.user", "*.vcxproj.filters"})
Utils.removeFiles(Global.gameDir .. "/**", {"*.sln", "*.vcxproj", "*.vcxproj.user", "*.vcxproj.filters"})
Utils.removeFiles(Global.depDir .. "/*/*", {"*.sln", "*.vcxproj", "*.vcxproj.user", "*.vcxproj.filters"})

print("Building environment for " .. Global.name .. "...")
os.mkdir(Global.binDir)
os.mkdir(Global.objDir)

-----------------------------
-- Define Workspace
-----------------------------

workspace(Global.name)
   startproject(Global.name)
   architecture "x64"
   configurations { "Dev" }

   filter "configurations:Dev"
      runtime "Debug"
      optimize "Off"
      symbols "On"

   filter "action:vs*"
      buildoptions { "/MP" }

   filter "system:windows"
      buildoptions { "/EHsc", "/Zc:preprocessor", "/Zc:__cplusplus" }
      systemversion "latest"

   filter {}

   group "Dependencies"
      include (Global.depDir .. "/Build-Raylib.lua")
   group ""

   include (Global.gameDir .. "/Source/Build-Game.lua")
