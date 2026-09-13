-----------------------------
-- Local
-----------------------------

local projectName = Global.name
local projectPath = Global.gameDir .. "/Source"

-----------------------------
-- Define Project
-----------------------------

project (projectName)
   kind "ConsoleApp"
   language "C++"
   cppdialect "C++20"
   staticruntime "on"

   defines { 'GAME_NAME="' .. Global.name .. '"'}

   targetdir (Global.outProjectDir)
   objdir (Global.objProjectDir)
   targetname (projectName)
   warnings "Extra"

   includedirs { projectPath }

   files {
      projectPath .. "/**.h",
      projectPath .. "/**.c",
      projectPath .. "/**.hpp",
      projectPath .. "/**.cpp",
   }

   Link.Raylib()
