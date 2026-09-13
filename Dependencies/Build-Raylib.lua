-----------------------------
-- Local
-----------------------------

local projectName = "Raylib"
local projectPath = Global.depDir .. '/' .. projectName

local function filterSetup()
   filter {"options:graphics=opengl43"}
      defines{"GRAPHICS_API_OPENGL_43"}

   filter {"options:graphics=opengl33"}
      defines{"GRAPHICS_API_OPENGL_33"}

   filter {"options:graphics=opengl21"}
         defines{"GRAPHICS_API_OPENGL_21"}

   filter {"options:graphics=opengl11"}
      defines{"GRAPHICS_API_OPENGL_11"}

   filter {"options:graphics=openges3"}
      defines{"GRAPHICS_API_OPENGL_ES3"}

   filter {"options:graphics=openges2"}
      defines{"GRAPHICS_API_OPENGL_ES2"}

   filter "system:windows"
      links {"winmm", "gdi32", "opengl32"}
      defines { "WIN32_LEAN_AND_MEAN" }

   filter "system:linux"
      buildoptions { "-fPIC" }
      links {
         "m",
         "pthread",
         "dl",
         "rt",
         "asound",
         "X11",
         "Xrandr",
         "Xi",
         "GL",
         "GLU",
         "Xcursor",
         "Xinerama",
         "wayland-client",
         "xkbcommon"
      }
      defines { "_GLFW_X11", "_GNU_SOURCE" }

   filter "action:vs*"
      characterset("MBCS")

   filter{}
end

-----------------------------
-- Fetch Dependency
-----------------------------

Utils.fetchRepoByRevision(projectPath, "https://github.com/raysan5/raylib.git", "dbc56a87da87d973a9c5baa4e7438a9d20121d28")

-----------------------------
-- Define Project
-----------------------------

project(projectName)
   kind "StaticLib"
   language "C"
   cdialect "C99"
   staticruntime "on"

   defines { "PLATFORM_DESKTOP" }
   filterSetup()

   location (projectPath)
   targetdir (Global.outProjectDir)
   objdir (Global.objProjectDir)
   warnings "Off"

   includedirs { 
      projectPath .. "/src",
      projectPath .. "/src/external/glfw/include"
   }

   files {
      projectPath .. "/src/*.h",
      projectPath .. "/src/*.c"
   }

   removefiles { projectPath .. "/src/rcore_*.c" }

   vpaths {
      ["Header Files"] = { projectPath .. "/src/**.h"},
      ["Source Files/*"] = { projectPath .. "/src/**.c"},
   }

-----------------------------
-- Link Export Function
-----------------------------

Link[projectName] = function()
   links { projectName }
   dependson { projectName }

   libdirs { Global.libProjectDir .. "/" .. projectName }
   includedirs {
      projectPath .. "/src",
      projectPath .. "/src/external",
      projectPath .. "/src/external/glfw/include"
   }

   -- The .lib needs to be explicitly linked here to avoid a macro CloseWindow redefinition
   filter "system:windows"
      defines { "NOGDI", "NOUSER", "WIN32_LEAN_AND_MEAN" }
      links { projectName .. ".lib" }
   filter {}
end
