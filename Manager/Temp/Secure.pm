package Manager::AM::Secure;

# script to secure the laptop quickly

sub QuicklySecureComputer {
  # umount encrypted directories
  system "cdetach classified";
  system "cdetach secure";

  # force logout on all virtual terminals

  # password protect the system
  # xlock -mode flag -message "Thank You for the Treats!"
  system "xlock -mode matrix";
}

1;
