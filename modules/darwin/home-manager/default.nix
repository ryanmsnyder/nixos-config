{ config, pkgs, lib, home-manager, user, ... }:

let
#   sharedFiles = import ../shared/files.nix { inherit config pkgs; };
#   additionalFiles = import ./files.nix { inherit user config pkgs; };

  # Import the scripts
  scripts = import ./scripts { inherit pkgs; };

  # Define scripts as a separate variable
  darwinScripts = builtins.attrValues scripts;


in

{
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  homebrew = {
    enable = true;
    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    # These apps won't be automatically uninstalled if removed
    masApps = {
      "magnet" = 441258766;
      "bitwarden" = 1352778147;  # currently not in nixpkgs for darwin so install via mas
      "amphetamine" = 937984704;
      "numbers" = 409203825;
    };
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, lib, ... }: {
      home = {
        enableNixpkgsReleaseCheck = false;
        # Packages/apps that will only be exposed to the user via ~/.nix-profile
        # packages = pkgs.callPackage ./packages.nix {};
        packages = pkgs.callPackage ./packages.nix {} ++ darwinScripts;
        # file = lib.mkMerge [
        #   sharedFiles
        #   additionalFiles
        # ];
        file.".config/karabiner/karabiner.json".source = ../../shared/home-manager/config/karabiner/karabiner.json;

        stateVersion = "23.11";
      };

        # Import home-manager programs shared between MacOS and nixOS
        imports = [
          ../../shared/home-manager
        ];


      # Marked broken Oct 20, 2022 check later to remove this
      # https://github.com/nix-community/home-manager/issues/3344
      manual.manpages.enable = false;
    };
  };

  system.defaults = {
    # Mouse tracking speed
    ".GlobalPreferences"."com.apple.mouse.scaling" = 9.0;

    NSGlobalDomain = {
      # Enable Dark mode
      AppleInterfaceStyle = "Dark";

      AppleShowAllExtensions = true;
      ApplePressAndHoldEnabled = false;

      # Key repeat settings
      KeyRepeat = 2;
      InitialKeyRepeat = 15;

      # Mouse and sound settings
      "com.apple.mouse.tapBehavior" = 1;
      "com.apple.sound.beep.volume" = 0.0;
      "com.apple.sound.beep.feedback" = 0;

      # Disable automatic capitalization and spelling correction
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
    };

    dock = {
      autohide = true;  # hide dock
      autohide-delay = 0.00;  # delay before dock shows
      autohide-time-modifier = 0.50;  # speed of dock animation when showing/hiding
      show-recents = false;
      launchanim = true;
      orientation = "bottom";
      tilesize = 48;
      wvous-bl-corner = 4; # hot corner that shows desktop when hovering mouse over bottom left corner
      mouse-over-hilite-stack = true; # highlight effect that follows the mouse in a Dock stack
      persistent-apps = [
        "${pkgs.wezterm}/Applications/WezTerm.app"
        "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app"
        "${pkgs.vscode}/Applications/Visual\ Studio\ Code.app/"
        "${config.users.users.${user}.home}/.nix-profile/Applications/Bruno.app"
        "${pkgs.obsidian}/Applications/Obsidian.app"
        "${pkgs.spotify}/Applications/Spotify.app"
        "/System/Applications/Reminders.app"
        "/System/Applications/Calendar.app"
      ];
      # persistent-others = [ "/Users/${user}/Downloads" ];
    };

    finder = {
      _FXShowPosixPathInTitle = true;
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      CreateDesktop = false;
      QuitMenuItem = true;
      ShowPathbar = true;
      ShowStatusBar = true;
    };

    trackpad = {
      Clicking = true; # enable trackpad tap to click
      TrackpadRightClick = true; # enable trackpad right click
      TrackpadThreeFingerDrag = true;
    };

    magicmouse = {
      # Enable secondary click on magic mouse when clicking the right side
      MouseButtonMode = "TwoButton";
    };

    # manages Apple plist settings in ~/Library/Preferences
    CustomUserPreferences = {
    # Raycast settings. Launch Raycast with CMD-SPC
      "com.raycast.macos" = {
        NSNavLastRootDirectory = "~/src/scripts/raycast";
        "NSStatusItem Visible raycastIcon" = 0;
        commandsPreferencesExpandedItemIds = [
          "extension_noteplan-3__00cda425-a991-4e4e-8031-e5973b8b24f6"
          "builtin_package_navigation"
          "builtin_package_scriptCommands"
          "builtin_package_floatingNotes"
        ];
        "emojiPicker_skinTone" = "mediumLight";
        initialSpotlightHotkey = "Command-49";  
        navigationCommandStyleIdentifierKey = "legacy";
        onboardingCompleted = true;
        "onboarding_canShowActionPanelHint" = 0;
        "onboarding_canShowBackNavigationHint" = 0;
        "onboarding_completedTaskIdentifiers" = [
          "startWalkthrough"
          "calendar"
          "setHotkeyAndAlias"
          "snippets"
          "quicklinks"
          "installFirstExtension"
          "floatingNotes"
          "windowManagement"
          "calculator"
          "raycastShortcuts"
          "openActionPanel"
        ];
        organizationsPreferencesTabVisited = 1;
        popToRootTimeout = 60;
        raycastAPIOptions = 8;
        raycastGlobalHotkey = "Command-49"; # launch Raycast with command-space
        raycastPreferredWindowMode = "default";
        raycastShouldFollowSystemAppearance = 1;
        raycastWindowPresentationMode = 1;
        showGettingStartedLink = 0;
        "store_termsAccepted" = 1;
        suggestedPreferredGoogleBrowser = 1;
        "permissions.folders.read:/Users/${user}/Desktop" = 1;
        "permissions.folders.read:/Users/${user}/Documents" = 1;
        "permissions.folders.read:/Users/${user}/Downloads" = 1;
        "permissions.folders.read:cloudStorage" = 1;
      };

      "com.apple.finder" = {
        _FXSortFoldersFirst = true;
        FXDefaultSearchScope = "SCcf"; # Search current folder by default
        ShowExternalHardDrivesOnDesktop = false;
        ShowHardDrivesOnDesktop = false;
        ShowMountedServersOnDesktop = false;
        ShowRemovableMediaOnDesktop = false;
      };

      # "com.apple.Safari" = {
      #   # Privacy: don’t send search queries to Apple
      #   UniversalSearchEnabled = false;
      #   SuppressSearchSuggestions = true;
      #   # Press Tab to highlight each item on a web page
      #   WebKitTabToLinksPreferenceKey = true;
      #   ShowFullURLInSmartSearchField = true;
      #   # Prevent Safari from opening ‘safe’ files automatically after downloading
      #   AutoOpenSafeDownloads = false;
      #   ShowFavoritesBar = true;
      #   IncludeInternalDebugMenu = false;
      #   IncludeDevelopMenu = true;
      #   WebKitDeveloperExtrasEnabledPreferenceKey = true;
      #   WebContinuousSpellCheckingEnabled = true;
      #   WebAutomaticSpellingCorrectionEnabled = false;
      #   AutoFillFromAddressBook = true;
      #   AutoFillCreditCardData = true;
      #   AutoFillMiscellaneousForms = true;
      #   WarnAboutFraudulentWebsites = true;
      #   WebKitJavaEnabled = false;
      #   WebKitJavaScriptCanOpenWindowsAutomatically = false;
      #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks" = true;
      #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;
      #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled" = false;
      #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled" = false;
      #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles" = false;
      #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically" = false;
      # };

      "com.apple.mail" = {
        # Disable inline attachments (just show the icons)
        DisableInlineAttachmentViewing = true;
      };

      "com.apple.screensaver" = {
        # Don't require password until 10 minutes after sleep or screen saver begins
        askForPassword = 0;
        askForPasswordDelay = 600;
      };

      "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;

      "com.apple.AdLib" = { allowApplePersonalizedAdvertising = false; };

    };
  };

  launchd.user.agents.raycast.serviceConfig = {
    Disabled = false;
    ProgramArguments = [ "/Applications/Raycast.app/Contents/Library/LoginItems/RaycastLauncher.app/Contents/MacOS/RaycastLauncher" ];
    RunAtLoad = true;
  };

  # disable Spotlight's CMD-SPC hotkey so Raycast can use it (no restart needed for this to work)
  # only applies to current user
  system.activationScripts.preUserActivation.text = ''
    defaults write com.apple.symbolichotkeys.plist AppleSymbolicHotKeys -dict-add 64 "
    <dict>
      <key>enabled</key><false/>
      <key>value</key><dict>
        <key>type</key><string>standard</string>
        <key>parameters</key>
        <array>
          <integer>32</integer>
          <integer>49</integer>
          <integer>1048576</integer>
        </array>
      </dict>
    </dict>
    "

    defaults write com.apple.dock persistent-others -array "
    <dict>
      <key>tile-data</key>
      <dict>
        <key>arrangement</key>
        <integer>1</integer>
        <key>displayas</key>
        <integer>1</integer>
        <key>file-data</key>
        <dict>
          <key>_CFURLString</key>
          <string>file:///Users/${user}/Downloads</string>
          <key>_CFURLStringType</key>
          <integer>15</integer>
        </dict>
        <key>file-type</key>
        <integer>2</integer>
        <key>showas</key>
        <integer>2</integer>
      </dict>
      <key>tile-type</key>
      <string>directory-tile</string>
    </dict>
    "
    
  '';

  system.activationScripts.postActivation.text = ''
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    killall Dock
  '';

}
