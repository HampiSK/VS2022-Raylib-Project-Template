project "Test"
   kind "ConsoleApp"
   language "C++"
   cppdialect "C++latest"
   staticruntime "off"

   targetdir (outputdir)
   objdir (intermediatesdir)

   defines { "TEST_MODE" }

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

   Link.Game()
   Link.Googletest()
   dependson { "Game", "Googletest" }
