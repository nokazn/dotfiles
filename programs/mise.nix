{ ... }:

{
  enable = true;
  enableBashIntegration = true;
  enableZshIntegration = true;
  globalConfig.tools = {
    node = "lts";
    yarn = "latest";
    pnpm = "latest";
    bun = "latest";
    go = "latest";
    uv = "latest";
  };
}
