#!/bin/bash
# http://lifehacker.com/how-to-make-your-own-bulk-app-installer-for-os-x-1586252163

#----------VARIABLES---------
	# Change the variables below per your environment
	orgName="com.jacobsalmela.scripts"
	loginWindowText=$(hostname)
	osVersion=$(sw_vers -productVersion | awk -F. '{print $2}')
    	swVersion=$(sw_vers -productVersion)
    	currentDate=$(date +"%Y-%m-%d %H:%M:%S")

#----------FUNCTIONS---------
###############################
function installEssentialApps()
	{
	echo -e "\tCleaning Launchpad..."
	sqlite3 ~/Library/Application\ Support/Dock/*.db "DELETE from apps; DELETE from groups WHERE title<>''; DELETE from items WHERE rowid>2;"; killall Dock

	brew update
	brew tap caskroom/cask
	brew install caskroom/cask/brew-cask
	
	# Install better browsers
	brew cask install google-chrome
	brew cask install firefox
	
	# Backup and syncing
	brew cask install dropbox
	
	# OS improvements
	brew cask install deathtodsstore
	
	echo -e "\Hiding  /opt..."
	sudo chflags hidden /opt
	}

###########################
function quickLookPlugins()
	{
	# QuickLook Enhancements
	brew cask install qlcolorcode
	brew cask install qlimagesize
	brew cask install qlmarkdown
	brew cask install qlprettypatch
	brew cask install qlrest
	brew cask install qlstephen
	brew cask install quicklook-csv
	brew cask install quicklook-json
	brew cask install quicklook-pfm
	
	# ScriptQL QuickLook Plugin
	#curl -o ~/Downloads/ScriptQL_qlgenerator.zip http://www.kainjow.com/downloads/ScriptQL_qlgenerator.zip 
	#unzip ~/Downloads/ScriptQL_qlgenerator.zip
	#rm ~/Downloads/ScriptQL_qlgenerator.zip

	# SuspiciousPackage QuickLook Plugin
	curl -o ~/Downloads/SuspiciousPackage.dmg http://www.mothersruin.com/software/downloads/SuspiciousPackage.dmg
	hdiutil mount ì/Downloads/SuspiciousPackage.dmg
	cp -R /Volumes/Suspicious\ Package/Suspicious\ Package.qlgenerator/ ~/Library/QuickLook/Suspicious\ Package.qlgenerator
	umount /Volumes/Suspicious\ Package/
	rm ~/Downloads/SuspiciousPackage.dmg

	# Archive QuickLook Plugin
	#curl -o ~/Downloads/Archive.zip http://www.qlplugins.com/sites/default/files/plugins/Archive.zip
	#unzip ~/Downloads/Archive.zip
	#mv ~/Downloads/Archive/Archive.qlgenerator ~/Library/QuickLook/Archive.qlgenerator
	#rm -rf ~/Downloads/Archive
	#rm ~/Downloads/Archive.zip

	# QLEnscript QuickLook Plugin
	#curl -o ~/Downloads/QLEnscript.qlgenerator-1.0.zip http://www.qlplugins.com/sites/default/files/plugins/QLEnscript.qlgenerator-1.0.zip
	#unzip ~/Downloads/QLEnscript.qlgenerator-1.0.zip
	#mv ~/Downloads/QLEnscript.qlgenerator ~/Library/QuickLook/
	#rm ~/Downloads/QLEnscript.qlgenerator-1.0.zip
	}

##########################
function resetQuickLook()
	{
	echo -e "\tResetting QuickLook..."
	# Reset QuickLook plugins
	qlmanage -r
	# Reload QuickLook cache
	qlmanage -r cache

	# Remove QuickLook plists
	rm ~/Library/Preferences/com.apple.quicklookconfig.plist
	rm ~/Library/Preferences/com.apple.QuickLookDaemon.plist
	}
	
##########################
function systemSettings()
	{
    	echo "******Deploying system-wide settings******"
    
	echo -e "\tEnabling access to assistive devices..."
	case ${OSTYPE} in
		darwin10*) sudo touch /private/var/db/.AccessibilityAPIEnabled;;
 		darwin11*) sudo touch /private/var/db/.AccessibilityAPIEnabled;;
 		darwin12*) sudo touch /private/var/db/.AccessibilityAPIEnabled;;
 		darwin13*) sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','com.apple.RemoteDesktopAgent',0,1,1,NULL);";
 				sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','com.apple.LockScreen',0,1,1,NULL);";
 		            	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','com.apple.systemevents',0,1,1,NULL);";
 		        	sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','/usr/bin/say',0,1,1,NULL);";
 				sudo sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db "INSERT or REPLACE INTO access VALUES('kTCCServiceAccessibility','/usr/bin/osascript',0,1,1,NULL);";;
 	esac

	echo -e "\tDisabling prompt to use drives for Time Machine..."
    	sudo defaults write /Library/Preferences/com.apple.TimeMachine.plist DoNotOfferNewDisksForBackup -bool true
    
    	echo -e "\tDisabling external accounts..."
    	# Disable external accounts (i.e. accounts stored on drives other than the boot drive.)
    	sudo defaults write /Library/Preferences/com.apple.loginwindow.plist EnableExternalAccounts -bool false

	echo -e "\tAdding information to login window..."
	sudo defaults write /Library/Preferences/com.apple.loginwindow.plist AdminHostInfo HostName

	echo -e "\tSetting a login banner that reads: $loginWindowText..."
	sudo defaults write /Library/Preferences/com.apple.loginwindow.plist LoginwindowText "$loginWindowText"

	echo -e "\tExpanding the print dialog by default..."
	sudo defaults write /Library/Preferences/.GlobalPreferences.plist PMPrintingExpandedStateForPrint -bool true
	sudo defaults write /Library/Preferences/.GlobalPreferences.plist PMPrintingExpandedStateForPrint2 -bool true

	echo -e "\tExpanding the save dialog by default..."
	sudo defaults write /Library/Preferences/.GlobalPreferences.plist NSNavPanelExpandedStateForSaveMode -bool true
	sudo defaults write /Library/Preferences/.GlobalPreferences.plist NSNavPanelExpandedStateForSaveMode2 -bool true

	echo -e "\tEnabling full keyboard access..."
	# Enable full keyboard access (tab through all GUI buttons and fields, not just text boxes and lists)
	sudo defaults write /Library/Preferences/.GlobalPreferences.plist AppleKeyboardUIMode -int 3
	
	echo -e "\tSpeeding up the shutdown delay..."
	sudo defaults write /System/Library/LaunchDaemons/com.apple.coreservices.appleevents.plist ExitTimeOut -int 5
	sudo defaults write /System/Library/LaunchDaemons/com.apple.securityd.plist ExitTimeOut -int 5
	sudo defaults write /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist ExitTimeOut -int 5
	sudo defaults write /System/Library/LaunchDaemons/com.apple.diskarbitrationd.plist ExitTimeOut -int 5
	sudo defaults write /System/Library/LaunchAgents/com.apple.coreservices.appleid.authentication.plist ExitTimeOut -int 5
	
	echo -e "\tDisabling Spotlight indexing on /Volumes..."
	sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"
	
	echo -e "\tDisabling smart-quotes and smart-dashes..."
	sudo defaults write /Library/Preferences/.GlobalPreferences.plist NSAutomaticQuoteSubstitutionEnabled -bool false
	sudo defaults write /Library/Preferences/.GlobalPreferences.plist NSAutomaticDashSubstitutionEnabled -bool false
	
	echo -e "\tMaking scrollbars always visible..."
	sudo defaults write /Library/Preferences/.GlobalPreferences.plist AppleShowScrollBars -string "Always"
	
	echo -e "\tDisabling crash report dialogs..."
	sudo defaults write com.apple.CrashReporter DialogType none
	
	echo -e "\tEnabling secure virtual memory..."
	sudo defaults write /Library/Preferences/com.apple.virtualMemory UseEncryptedSwap -bool yes
	
	echo -e "\tSetting time to 24-hour..."
	sudo defaults write NSGlobalDomain AppleICUForce24HourTime -bool true
	
	echo -e "\tEnabling tap-to-click..."
	defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
	defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
	defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
	
	ssdCheck=$(diskutil info / | awk '/Solid State/ {print $3}')
	if [ $ssdCheck = "Yes" ];then
		echo -e "\tSolid State Drive detected..."
		# https://github.com/mathiasbynens/dotfiles/blob/master/.osx
		echo -e "\t\tDisabling Time Machine local snapshots..."
		sudo tmutil disablelocal
	
		echo -e "\t\tDisabling hibernation..."
		sudo pmset -a hibernatemode 0
	
		echo -e "\t\tRemoving the sleep image..."
		sudo rm /Private/var/vm/sleepimage
		sudo touch /Private/var/vm/sleepimage
		sudo chflags uchg /Private/var/vm/sleepimage
	
		echo -e "\t\tDisabling Sudden Motion Sensor..."
		sudo pmset -a sms 0
	else
		echo -e "\tRotational hard disk detected.  No additional setting..."
	fi
	}
	
#########################
function finderSettings()
	{
	# Case is different in finder plist starting in 10.9
	case ${OSTYPE} in
		darwin10*) finderCase="Finder";;
 		darwin11*) finderCase="Finder";;
 		darwin12*) finderCase="Finder";;
 		darwin13*) finderCase="finder";;
 	esac
	
	echo "******Deploying Finder settings******"
		
	echo "**---------------FINDER--------"
			
	echo -e "\tSetting home folder as the default location for new Finder windows..."
	defaults write com.apple.$finderCase NewWindowTarget -string "PfLo"
	defaults write com.apple.$finderCase NewWindowTargetPath -string "file://${HOME}/"

	echo -e "\tShowing Hard Drives on Desktop..."
	defaults -currentHost write com.apple.$finderCase ShowHardDrivesOnDesktop -bool YES
	echo -e "\tShowing External Hard Drives on Desktop..."
	defaults -currentHost write com.apple.$finderCase ShowExternalHardDrivesOnDesktop -bool YES
	echo -e "\tShowing Servers on Desktop..."
	defaults -currentHost write com.apple.$finderCase ShowMountedServersOnDesktop -bool YES
	echo -e "\tShowing removeable media on Desktop..."
	defaults -currentHost write com.apple.$finderCase ShowRemovableMediaOnDesktop -bool YES
	
	echo -e "\tSetting Finder to column view..."
	defaults write com.apple.$finderCase FXPreferredViewStyle -string "clmv"

	echo -e "\tSetting Finder to search the current folder..."
	defaults write com.apple.$finderCase FXDefaultSearchScope -string "SCcf"

	echo -e "\tShowing status bar..."
	defaults write com.apple.$finderCase ShowStatusBar -bool true

	echo -e "\tShowing path bar..."
	defaults write com.apple.$finderCase ShowPathbar -bool true

	echo -e "\tShowing POSIX path bar..."
	defaults write com.apple.$finderCase _FXShowPosixPathInTitle -bool true

	echo -e "\tEnabling QuickLook text-selection..."
	defaults write com.apple.$finderCase QLEnableTextSelection -bool TRUE

	echo -e "\tEnabling QuickLook x-ray vision..."
	defaults write com.apple.$finderCase QLEnableXRayFolders -bool true

	echo -e "\tMaking Finder animations faster..."
	defaults write com.apple.$finderCase DisableAllAnimations -bool true

	echo -e "\tShowing all file extensions..."
	defaults write NSGlobalDomain AppleShowAllExtensions -bool true
		
	# Expand the following File Info panes:
	echo -e "\tShowing General, Open with, and Sharing & Permissions on the Get Info window..."
	defaults write com.apple.$finderCase FXInfoPanesExpanded -dict \
		General -bool true \
		OpenWith -bool true \
		Privileges -bool true
	
	echo -e "\tDeath to network .DS_Stores..."
	defaults write com.apple.desktopservices DSDontWriteNetworkStores true
	
	echo -e "\tMaking window animations faster..."
	defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
	defaults write com.apple.$finderCase DisableAllAnimations -bool true

	echo -e "\tMaking QuickLook anitmation faster..."
	defaults write -g QLPanelAnimationDuration -float 0
	
	echo -e "\tMaking the ~/Library folder visible for $adminUser..."
	chflags nohidden ~/Library/
	}
	
#######################	
function dockSettings()
	{
	echo "******Deploying Dock settings******"

	echo "**---------------DOCK--------"
		
	echo -e "\tMaking spaces static..."
	defaults write com.apple.dock mru-spaces -bool false

	echo -e "\tMaking hidden apps translucent..."
	defaults write com.apple.dock showhidden -bool true

	echo -e "\tRemoving dock auto hide delay..."
	defaults write com.apple.dock autohide-delay -float 0
	
	echo -e "\tMaking dock faster..."
	defaults write com.apple.dock autohide-time-modifier -float 0

	echo -e "\tMaking Mission Control faster..."
	defaults write com.apple.dock expose-animation-duration -float 0
	
	echo -e "\tEnabling spring-loading for all dock apps..."
	defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true
		
	echo -e "\tMaking maximize/minimize to scale mode..."
	defaults write com.apple.dock mineffect -string "scale"


	echo -e "\tSetting top-left corner to Mission Control..."
	defaults write com.apple.dock wvous-tl-corner -int 2		# Mission Control
	defaults write com.apple.dock wvous-tl-modifier -int 0

	echo -e "\tSetting top-right corner to Notification Center..."
	defaults write com.apple.dock wvous-tr-corner -int 12		# Notification Center
	defaults write com.apple.dock wvous-tr-modifier -int 0

	echo -e "\tSetting bottom-left corner to Show Desktop..."
	defaults write com.apple.dock wvous-bl-corner -int 4		# Show Desktop
	defaults write com.apple.dock wvous-bl-modifier -int 0

	echo -e "\tSetting bottom-right corner to Launchpad..."
	defaults write com.apple.dock wvous-br-corner -int 11		# Launchpad
	defaults write com.apple.dock wvous-br-modifier -int 0
		
	echo -e "\tDisabling Dashboard..."
	defaults write com.apple.dashboard mcx-disabled -boolean YES
	}
		
########################
function otherSettings()
	{
	echo "******Deploying misc. settings******"
	
	echo "**------------MISC---------"

	echo -e "\tIncreasing mouse tracking to 3..."
	defaults write -g com.apple.mouse.scaling -float 3

	echo -e "\tIncreasing trackpad tracking to 3..."
	defaults write -g com.apple.trackpad.scaling -int 3
	
	echo -e "\tDisabling volume change feedback..."
	defaults write -g com.apple.sound.beep.feedback -int 0

	echo -e "\tEnabling Airdrop over Ethernet..."
	defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

	echo -e "\tImproving bash history..."
	echo "HISTTIMEFORMAT="%Y-%m-%d %T"" > ~/.bash_profile
	echo "HISTFILESIZE=65535" >> ~/.bash_profile
	echo "export PROMPT_COMMAND='history -a'" >> ~/.bash_profile

	echo -e "\tMaking Safari search banners using Contains instead of Starts With..."
	defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false
		
	echo -e "\tSetting default Safari Webpage..."
	defaults write com.apple.Safari HomePage -string "http://jacobsalmela.com"
	
	echo -e "\tIncreasing sound quality of Bluetooth and headphones..."
	defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40
	
	echo -e "\tDisabling iCloud as the default save location..."
	defaults write -g NSDocumentSaveNewDocumentsToCloud -bool false
	
	echo -e "\tMaking the scroll dragging speed faster..."
	defaults write -g NSAutoscrollResponseMultiplier -float 3
	
	echo -e "\tMaking symbolic link to airport utility..."
	sudo ln -s /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport /usr/sbin/airport
	
	echo -e "\tMaking symbolic link to Wireless Diagnostics utility..."
	sudo ln -s /System/Library/CoreServices/Applications/Wireless\ Diagnostics.app /Applications/Utilities/Wireless\ Diagnostics.app
	
	echo -e "\tMaking symbolic link to Network Utility..."
	sudo ln -s /System/Library/CoreServices/Applications/Network\ Utility.app /Applications/Utilities/Network\ Utility.app 
	
	echo -e "\tMaking symbolic link to Network Utility..."
	sudo ln -s /System/Library/CoreServices/Applications/Screen\ Sharing.app /Applications/Screen\ Sharing.app 
	}

##################################
function activityMonitorSettings()
	{
	echo "******Deploying Activity Monitor settings******"
	
	echo "**------------ACTIVITY MONITOR---------"

	echo -e "\tSetting the Dock icon to show CPU usage..."
	defaults write com.apple.ActivityMonitor IconType -int 5

	echo -e "\tShowing all processes by default..."
	defaults write com.apple.ActivityMonitor ShowCategory -int 100
	
	echo -e "\tMavericks: Adding the % CPU column to the Disk and Network tabs..."
	defaults write com.apple.ActivityMonitor "UserColumnsPerTab v4.0" -dict \
	    '0' '( Command, CPUUsage, CPUTime, Threads, IdleWakeUps, PID, UID )' \
	    '1' '( Command, anonymousMemory, Threads, Ports, PID, UID, ResidentSize )' \
	    '2' '( Command, PowerScore, 12HRPower, AppSleep, graphicCard, UID )' \
	    '3' '( Command, bytesWritten, bytesRead, Architecture, PID, UID, CPUUsage )' \
	    '4' '( Command, txBytes, rxBytes, txPackets, rxPackets, PID, UID, CPUUsage )'

	echo -e "\tMavericks: Sort by CPU usage in Disk and Network tabs..."
	defaults write com.apple.ActivityMonitor UserColumnSortPerTab -dict \
	    '0' '{ direction = 0; sort = CPUUsage; }' \
	    '1' '{ direction = 0; sort = ResidentSize; }' \
	    '2' '{ direction = 0; sort = 12HRPower; }' \
	    '3' '{ direction = 0; sort = CPUUsage; }' \
	    '4' '{ direction = 0; sort = CPUUsage; }'	
	}

#########################	
function safariSettings()
	{
	echo "******Deploying Safari settings******"
	
	echo "**------------SAFARI---------"
	
	echo -e "\tShowing status bar..."	
	defaults write com.apple.Safari ShowStatusBar -bool true

	echo -e "\tEnabling favorites bar..."
	defaults write com.apple.Safari ShowFavoritesBar -bool true	
	}

###############################
function yosemiteSpecific()
	{
	if [ ${OSTYPE} = darwin14* ];then 
		echo -e "\tEnabling dark mode..."
		defaults write /Library/Preferences/.GlobalPreferences AppleInterfaceTheme Dark	
	else
		echo "Not Yosemite"
	fi
	}

######################
function customPlist()
	{
	echo "******Writing to $orgName.plist******"
	sudo defaults read /Library/Preferences/"$orgName".plist KickstartDeployed
	if [ $? = 0 ];then
		sudo defaults write /Library/Preferences/"$orgName".plist KickstartDeployed "$currentDate"
	else
		sudo defaults write /Library/Preferences/"$orgName".plist KickstartDeployed "$currentDate"
	fi
	}
	
##################
function setDock()
	{
	/usr/bin/dockutil --remove all
	/usr/bin/dockutil --add /Applications/Safari.app 
	/usr/bin/dockutil --add /Applications/Firefox.app 
	/usr/bin/dockutil --add /Applications/Google\ Chrome.app 
	/usr/bin/dockutil --add /Applications/Spotify.app 
	/usr/bin/dockutil --add /Applications/System\ Preferences.app 
	killall Dock
	}
#------------------------------		
#-------BEGIN SCRIPT-----------
#------------------------------	
defaults read /Library/Preferences/"$orgName".plist KickstartDeployed
if [ $? = 0 ];then
	resetQuickLook
	systemSettings
	finderSettings
	dockSettings
	activityMonitorSettings
	safariSettings
	otherSettings
	yosemiteSpecific
	setDock
	customPlist
else
	killall Safari
	installEssentialApps
	quickLookPlugins
	resetQuickLook
	systemSettings
	finderSettings
	dockSettings
	activityMonitorSettings
	safariSettings
	otherSettings
	setDock
	yosemiteSpecific
	customPlist
fi
echo "******COMPLETE******"
echo -e "\n\n*********************************"
echo -e "\n\nReboot now to apply all settings."
echo -e "\n\n*********************************"
