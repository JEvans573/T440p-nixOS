# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
     # ./overlays.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sdb";
  boot.loader.grub.useOSProber = true;

  #attempt at OpenBSD dual boot settings
  # boot.loader.grub.extraEntries = "
  # menuentry "OpenBSD (hd1,gpt

  boot.kernelPackages = pkgs.linuxPackages_latest;
  # Setup keyfile
  boot.initrd.secrets = {
    "/boot/crypto_keyfile.bin" = null;
  };

  boot.loader.grub.enableCryptodisk = true;

  boot.initrd.luks.devices."luks-685a8ff6-38b6-4250-b78d-df36d567d9bf".keyFile = "/boot/crypto_keyfile.bin";
  networking.hostName = "nixos-alephwyr"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  services.connman.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

# enable gnome-keyring screts vault
  # services.gnome.gnome-keyring.enable = true;

# zfs enable
boot.supportedFilesystems = ["ext" "zfs" "vfat" ];
networking.hostId = "b0df8406";
boot.loader.grub.copyKernels = true;

# shutdown commands for preserving zfs pool with external hdd dock
 systemd.services.my-shutdown-script = {
   serviceConfig.Type = "oneshot";
   script = "zpool export -a | echo 'zpools exported' | tee /tmp/shutdown_log.txt ";
   unitConfig.Conflicts = "reboot.target poweroff.target hibernate.target suspend.target";
   unitConfig.Before = "reboot.target poweroff.target hibernate.target suspend.target";
   wantedBy = [ "multi-user.target" ];
};

  # enable Sway
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
   };
  programs.dconf.enable = true;

  # Enable the K Desktop Environment.
  # services.displayManager.sddm.wayland.enable = true;
  # services.desktopManager.plasma6.enable = true;

  # jellyfin
  services.jellyfin = { 
  enable = true;
  openFirewall = true;
  user = "alephwyr";
   };

  # enable kubernetes
  services.k3s.enable = true;
  services.k3s.role = "server";
  networking.firewall.allowedTCPPorts = [ 6443 ];

  # enable fail2ban
  services.fail2ban = {
    enable = true;
    # Ban IP after 3 failures
    maxretry = 3;
    bantime = "72h";
    bantime-increment = {
      enable = true;
      # formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
      multipliers = "1 2 4 8 16 32 64";
      overalljails = true;
    };
    #jails = {
      #DEFAULT = {
        # destemail = "root@127.0.0.1";
        # sender = "root@${config.networking.hostName}.${config.networking.domain}";
        # mta = "sendmail";
        # };
      # NixOS wiki says I don't need this but leaving it here for syntax reference
      # ssh = {
      #  enabled = true;
      #  port = "ssh";
      #  };
      #};
    };
  # system.msmtp.enable = true;

  # Enable hyprland for Steam
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
 };
  # Alleged Intel driver fix
  programs.gamemode.enable = true;
  programs.gamescope.enable = true;
  hardware.graphics = {
  enable = true;
  enable32Bit = true;
  extraPackages = with pkgs; [
    intel-media-sdk
    intel-ocl
    libva-vdpau-driver
    intel-vaapi-driver
      ];
  };


  # setting open source intel driver with Glamor (OpenGL acceleration)
  # services.xserver.videoDrivers = [ "modesetting" ];
  # ovpn config
  services.openvpn.servers.vpn = {
  config = "config /etc/openvpn/us_california.ovpn";
  autoStart = false;
  updateResolvConf = true;
  # auth-user-pass = "/etc/openvpn/myvpn.cred";
};
  # greetd
   services.greetd.enable = true;
  # lemurs
  #services.lemurs = {
  # enable = true;
  # settings = {
  #   title = "Father Osiris, bless us with immortality. The chances aren't great, maybe one in a million. But biologically speaking, those are pretty good odds";
  #  title_color = "cyan";
  #  };
#};

#startplasma-wayland for kde
   services.greetd.settings = {
   default_session = {
     command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway"; 
     user = "greeter";
   };
}; 
  
  #getting interoperability working with wayland and different window/desktop stacks
  security.polkit.enable = true;
  services.dbus.enable = true;

  # Enable acpid
  services.acpid.enable = true;

  # Enable Flatpak
  services.flatpak.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alephwyr = {
    isNormalUser = true;
    description = "Jessica Evans";
    extraGroups = [ "networkmanager" "wheel" "disk" "audio" "video" "dialout" "seat"];
    packages = with pkgs; [
    #  thunderbird
    ];
  };
  #virtual machine stuff
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["alephwyr"];
  virtualisation.libvirtd.enable = true;


  # Install firefox.
  programs.firefox.enable = false;
  programs.firejail.enable = true;
  #openvpn3
  programs.openvpn3.enable = true;
  programs.steam = {
  enable = false;
  remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
};
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  vim # command line things.  Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  bash
  coreutils
  wget
  curl
  rustup
  clisp
  python314
  perl
  scala_2_13
  gdb
  mysql84
  yarn
  yt-dlp
  git
  gh
  unzip
  neofetch
  system-sendmail
  glib
  glib.dev
  wine #game things
  obs-studio
  dosbox
  mednafen
  mednaffe
  retroarch
  vulkan-tools
  heroic
  lutris
  steam-devices-udev-rules
  discord #communications
  pkgs.kdePackages.konversation
  teams-for-linux
  zoom-us
  slack
  vscode-with-extensions #programming
  geany
  pkgs.godotPackages_4_4.godot
  libreoffice-fresh #office and document
  calibre
  vlc #media
  openshot-qt #editing
  gimp-with-plugins
  lmms
  virt-manager #virtualization
  virt-viewer
  pkgs.kdePackages.isoimagewriter #kde specific packages
  pkgs.kdePackages.kcalc
  pkgs.kdePackages.partitionmanager
  nicotine-plus
  tor #network
  fail2ban
  transmission_4-qt
  librewolf-unwrapped
  librewolf
  jellyfin
  jellyfin-web
  jellyfin-ffmpeg
  openvpn3
  wg-netmanager
  networkmanager-openvpn
  zfs #zfs config
  zfs-autobackup
  zfs-prune-snapshots
  linuxKernel.packages.linux_xanmod_stable.zfs_2_3
  sway #sway config
  swayidle
  sway-audio-idle-inhibit
  grim
  sway-contrib.grimshot
  swayimg
  swaybg
  swayws
  swaywsr
  swaylock
  sway-new-workspace
  sway-audio-idle-inhibit
  slurp
  mako
  libnotify
  wl-clipboard
  conky
  waybar
  waybar-mpris
  wttrbar
  rofi
  rofi-vpn
  rofi-calc
  rofi-games
  rofi-screenshot
  rofi-power-menu
  rofi-file-browser
  rofi-network-manager
  alacritty
  clipman
  mailspring #gmail
  xdg-desktop-portal
  xdg-desktop-portal-gtk
  xdg-desktop-portal-wlr
  lxappearance
  lemurs #login managers
  # greetd
  ];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
   programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
   };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
