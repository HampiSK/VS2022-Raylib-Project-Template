function platformDefines()
   defines{"PLATFORM_DESKTOP"}

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

   filter{}
end

function filtersSetup()
   filter "action:vs*"
      defines { "_WINSOCK_DEPRECATED_NO_WARNINGS", "_CRT_SECURE_NO_WARNINGS" }
      characterset("MBCS")

   filter "system:windows"
      defines { "_WIN32" }
      links { "winmm", "gdi32" }
      buildoptions { "/Zc:__cplusplus" }

   filter "system:linux"
      defines {"_GLFW_X11", "_GNU_SOURCE" }
      links { "pthread", "m", "dl", "rt", "X11" }
end

-- Download game engine if missing
Utils.downloadRepoByTagIfMissing(dependenciesdir .. "/Raylib", "https://github.com/raysan5/raylib.git", "5.0")

project "Raylib"
   kind "StaticLib"
   language "C"
   staticruntime "off"

   location (dependenciesdir .. "/Raylib")
   targetdir (outputdir)
   objdir (intermediatesdir)

   platformDefines()

   includedirs { 
      dependenciesdir .. "/Raylib/src",
      dependenciesdir .. "/Raylib/src/external/glfw/include"
   }

   files {
      dependenciesdir .. "/Raylib/src/*.h",
      dependenciesdir .. "/Raylib/src/*.c"
   }

   removefiles { dependenciesdir .. "/Raylib/src/rcore_*.c" }

   vpaths {
      ["Header Files"] = { dependenciesdir .. "/Raylib/src/**.h"},
      ["Source Files/*"] = { dependenciesdir .. "/Raylib/src/**.c"},
   }

   filtersSetup()

-- Link Export
-- Function to link Raylib project for other projects
function Link.Raylib()
   links { "Raylib" }
   libdirs { librariesdir .. "/Raylib" }

   includedirs {
      dependenciesdir .. "/Raylib/src",
      dependenciesdir .. "/Raylib/src/external",
      dependenciesdir .. "/Raylib/src/external/glfw/include"
   }

   platformDefines()

   filtersSetup()

   filter "action:vs*"
      links { "Raylib.lib" }
end
