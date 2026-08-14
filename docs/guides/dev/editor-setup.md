# Editor setup

Configure your editor to run Prettier on save, so files match this repo's `.prettierrc.json` without needing `pnpm format` before every commit.

- **VS Code**: install the recommended [Prettier extension](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode) (VS Code prompts for it automatically via `.vscode/extensions.json`), then add to your `settings.json`:

  ```json
  {
      "editor.defaultFormatter": "esbenp.prettier-vscode",
      "editor.formatOnSave": true
  }
  ```

- **WebStorm**: open Settings → Languages & Frameworks → JavaScript → Prettier, and check **Run on save**. WebStorm auto-detects the local `prettier` package and this repo's config.
