project "Game"
   kind "ConsoleApp"
   language "C++"
   cppdialect "C++latest"
   staticruntime "off"

   targetdir (outputdir)
   objdir (intermediatesdir)

   files {
      "%{prj.location}/**.h",
      "%{prj.location}/**.c",
      "%{prj.location}/**.hpp",
      "%{prj.location}/**.cpp",
   }

   includedirs {
      "%{prj.location}/**",
   }

   filter "system:windows"
      buildoptions { "/EHsc", "/Zc:preprocessor", "/Zc:__cplusplus" }
      systemversion "latest"

   Link.Raylib()

   dependson { "Raylib" }

-- Link Export
-- Function to link Game project for other projects
function Link.Game()
   links { "Game" }
   libdirs { librariesdir .. "/Game" }

   files {
      rootdir .. "/Game/Source/**.h",
      rootdir .. "/Game/Source/**.c",
      rootdir .. "/Game/Source/**.hpp",
      rootdir .. "/Game/Source/**.cpp",
   }

   removefiles { rootdir .. "/Game/Source/main.cpp" }

   includedirs {
      rootdir .. "/Game/Source",
   }

   filter "system:windows"
      buildoptions { "/EHsc", "/Zc:preprocessor", "/Zc:__cplusplus" }
      systemversion "latest"

   Link.Raylib()

   dependson { "Raylib" }
end
