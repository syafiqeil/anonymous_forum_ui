{
  description = "Anonymous Forum with Threshold Moderation — QML UI Module";

  inputs = {
    logos-module-builder.url = "github:logos-co/logos-module-builder";

    # Core module dependency — resolved automatically by collectAllModuleDeps
    anonymous_forum_core = {
      url = "github:syafiqeil/anonymous_forum_core";
    };
  };

  outputs = inputs@{ logos-module-builder, ... }:
    logos-module-builder.lib.mkLogosQmlModule {
      src = ./.;
      configFile = ./metadata.json;
      flakeInputs = inputs;
    };
}