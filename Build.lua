-- Globals

-- Define a project name
gamename = "AllOnRed"

-- Get path to a root directory
rootdir = os.getcwd()

-- Create directories if they don't exist
os.mkdir(rootdir .. "/Binaries")
os.mkdir(rootdir .. "/Binaries/Intermediates")
os.mkdir(rootdir .. "/Dependencies")

-- Define paths
outputdir = rootdir .. "/Binaries/%{cfg.system}-%{cfg.architecture}/%{cfg.buildcfg}/%{prj.name}"
librariesdir = rootdir .. "/Binaries/%{cfg.system}-%{cfg.architecture}/%{cfg.buildcfg}"
intermediatesdir = rootdir .. "/Binaries/Intermediates/%{cfg.system}-%{cfg.architecture}/%{cfg.buildcfg}/%{prj.name}"
dependenciesdir = rootdir .. "/Dependencies"

-- Define helpers
Utils = {}
include (rootdir .. "/Premake/Utils/Utils.lua")

Link = {}

-- Define workspace
workspace(gamename)
   architecture "x64"
   configurations { "Dev", "Release" }
   startproject "Game"

   -- Build configurations

   filter "configurations:Dev"
      defines { "DEVELOPMENT_MODE" }
      symbols "On"
      optimize "Off"
      runtime "Debug"

   filter "configurations:Release"
      defines { "RELEASE_MODE" }
      optimize "Full"

   -- Define projects

   group "Dependencies"
      include (rootdir .. "/Dependencies/Build-Dependencies.lua")
   group ""

   include (rootdir .. "/Game/Source/Build-Game.lua")
   include (rootdir .. "/Game/Test/Build-Test.lua")
