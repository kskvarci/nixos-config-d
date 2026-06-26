# SSH server
{
  nixos.modules.ssh = {
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = true;
        KbdInteractiveAuthentication = false;
        X11Forwarding = true;
        UsePAM = true;
      };
    };
  };
}
