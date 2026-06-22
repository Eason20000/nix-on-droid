# Copyright (c) 2019-2024, see AUTHORS. Licensed under MIT License, see LICENSE.

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.build;
in

{

  ###### interface

  options = {

    build = {
      initialBuild = mkOption {
        type = types.bool;
        default = false;
        internal = true;
        description = ''
          Whether this is the initial build for the bootstrap zip ball.
          Should not be enabled manually, see
          <filename>initial-build.nix</filename>.
        '';
      };

      installationDir = mkOption {
        type = types.path;
        internal = true;
        readOnly = true;
        description = "Path to installation directory.";
      };

      container = {
        mode = mkOption {
          type = types.enum [ "proot" "chroot" ];
          default = "proot";
          description = ''
            Container mode.

            <literal>"proot"</literal>: user-space via proot (ptrace),
            no root required.

            <literal>"chroot"</literal>: kernel-level via chroot,
            requires rooted device. /dev, /proc, /sys are
            bind-mounted, hardlinks and job control work natively.
            Proot fallback always available
            (<literal>NIX_ON_DROID_FORCE_PROOT=1</literal>).
          '';
        };
      };

      extraProotOptions = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          Extra options passed to proot, e.g., extra bind mounts.
          Ignored when <option>build.container.mode</option> is
          <literal>"chroot"</literal>.
        '';
      };

      extraChrootOptions = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "mount --bind /sdcard /sdcard" ];
        description = ''
          Extra shell commands executed before chroot, e.g.,
          additional bind mounts. Ignored when
          <option>build.container.mode</option> is
          <literal>"proot"</literal>.
        '';
      };
    };

  };


  ###### implementation

  config = {

    build.installationDir = "/data/data/com.termux.nix/files/usr";

    assertions = [
      {
        assertion = !(cfg.container.mode == "chroot" && cfg.extraProotOptions != [ ]);
        message = "`build.extraProotOptions` is set but `build.container.mode` is `\"chroot\"`";
      }
      {
        assertion = !(cfg.container.mode == "proot" && cfg.extraChrootOptions != [ ]);
        message = "`build.extraChrootOptions` is set but `build.container.mode` is `\"proot\"`";
      }
    ];

  };

}
