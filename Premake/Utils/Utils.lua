-- Function to download and unpack a Git repository if it's missing
function Utils.downloadRepoIfMissing(targetDir, repoUrl, repoBranch)
   if not os.isdir(targetDir) then
      print(targetDir .. " not found. Downloading from " .. repoUrl)
      local branchOption = branch and ("--branch " .. branch) or ""
      local command = string.format('git clone %s --verbose "%s" "%s"', branchOption, repoUrl, targetDir)
      print(command)
      os.execute(command)
      if os.isdir(targetDir) then
         print(targetDir .. " downloaded successfully.")
      else
         print("Failed to download " .. targetDir)
         os.exit(1)
      end
   end
end

-- Function to download and unpack a Git repository by tag if it's missing
function Utils.downloadRepoByTagIfMissing(targetDir, repoUrl, tag)
   if not os.isdir(targetDir) then
      local tagOption = tag and ("--branch " .. tag .. " --single-branch") or ""
      local command = string.format('git clone %s --verbose "%s" "%s"', tagOption, repoUrl, targetDir)
      print(command)
      os.execute(command)
      if os.isdir(targetDir) then
         print(targetDir .. " downloaded successfully.")
      else
         print("Failed to download " .. targetDir)
         os.exit(1)
      end
   end
end
