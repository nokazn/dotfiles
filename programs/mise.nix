{ ... }:

{
  enable = true;
  enableBashIntegration = true;
  enableZshIntegration = true;
  globalConfig.tools = {
    node = "26";
    yarn = "latest";
    pnpm = "latest";
    bun = "latest";
    go = "latest";
    uv = "latest";
  };
}
