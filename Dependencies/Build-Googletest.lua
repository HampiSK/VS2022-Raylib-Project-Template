-- Download dependency if missing
Utils.downloadRepoIfMissing(dependenciesdir .. "/Googletest", "https://github.com/google/googletest.git", "v1.14.x")

-- Define Google Test project
project "Googletest"
   kind "StaticLib"
   language "C++"
   staticruntime "off"

   targetdir (outputdir)
   objdir (intermediatesdir)

   includedirs {
      dependenciesdir .. "/Googletest/googletest",
      dependenciesdir .. "/Googletest/googletest/include",
      dependenciesdir .. "/Googletest/googlemock",
      dependenciesdir .. "/Googletest/googlemock/include",
   }

   files {
      dependenciesdir .. "/Googletest/googletest/src/*.cc",
      dependenciesdir .. "/Googletest/googlemock/src/*.cc"
   }

   filter "system:windows"
      defines { "GTEST_HAS_PTHREAD=0" }

-- Link Export
-- Function to link Googletest project for other projects
function Link.Googletest()
   links { "Googletest" }
   libdirs { librariesdir .. "/Googletest" }

   includedirs {
      dependenciesdir .. "/Googletest/googletest",
      dependenciesdir .. "/Googletest/googletest/include",
      dependenciesdir .. "/Googletest/googlemock",
      dependenciesdir .. "/Googletest/googlemock/include",
   }

   filter "system:windows"
      defines { "GTEST_HAS_PTHREAD=0" }
end
