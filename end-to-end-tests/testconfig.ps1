# Copyright (c) 2017 Chocolatey Software, Inc.
# Copyright (c) 2013 - 2017 Lawrence Gripper & original authors/contributors from https://github.com/chocolatey/cChoco
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

Install-PackageProvider -Name NuGet -Force -ErrorAction Stop
Install-Module cChoco -Force -ErrorAction Stop
Import-Module cChoco

Configuration myChocoConfig
{
   Import-DscResource -Module cChoco
   Node "localhost"
   {
      LocalConfigurationManager
      {
          DebugMode = 'ForceModuleImport'
      }
      cChocoInstaller installChoco
      {
        InstallDir = "C:\ProgramData\chocolatey"
      }
      cChocoSource hermes
      {
        Name = 'local'
        Source = 'c:\vagrant\packages\'
        DependsOn = "[cChocoInstaller]installChoco"
      }
      cChocoPackageInstaller installChocolatey
      {
        Name = 'chocolatey'
        DependsOn = "[cChocoSource]hermes"
        AutoUpgrade = $true
        Source = 'local'
      }
      cChocoPackageInstaller installChrome
      {
        Name        = "googlechrome"
        DependsOn   = "[cChocoPackageInstaller]installChocolatey"
        #This will automatically try to upgrade if available, only if a version is not explicitly specified.
        AutoUpgrade = $True
      }
      cChocoPackageInstaller installAtomSpecificVersion
      {
        Name = "glab"
        Version = "1.28.0"
        DependsOn = "[cChocoPackageInstaller]installChocolatey"
      }
      cChocoPackageInstaller installGit
      {
         Ensure = 'Present'
         Name = "git"
         DependsOn = "[cChocoPackageInstaller]installChocolatey"
      }
      cChocoPackageInstaller noFlashAllowed
      {
         Ensure = 'Absent'
         Name = "flashplayerplugin"
         DependsOn = "[cChocoPackageInstaller]installChocolatey"
      }
      cChocoPackageInstallerSet installSomeStuff
      {
         Ensure = 'Present'
         Name = @(
			"skype"
			"7zip"
		)
         DependsOn = "[cChocoPackageInstaller]installChocolatey"
      }
      cChocoPackageInstallerSet stuffToBeRemoved
      {
         Ensure = 'Absent'
         Name = @(
			"vlc"
			"vlc.install"
			"ruby"
			"adobeair"
		)
         DependsOn = "[cChocoPackageInstaller]installChocolatey"
      }
   }
}

myChocoConfig

Start-DscConfiguration .\myChocoConfig -wait -Verbose -force
