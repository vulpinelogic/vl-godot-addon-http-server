# Guidelines for contributing

Thanks for your interest in contributing! Before contributing, be sure to know
about these few guidelines:

- Follow the
  [GDScript style guide](https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_styleguide.html).
- Use [GDScript static typing](https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/static_typing.html) whenever possible.
- Make sure to update the changelog for any user-facing changes, keeping the
  [changelog format](http://keepachangelog.com/en/1.0.0/) in use.
- Don't bump the version yourself. Maintainers will do this when necessary.

## Design goals

This add-on aims to:

- Provide a basic GDScript-native HTTP server for tasks such as serving diagnostic pages or receiving OAUTH callbacks.
- Enable other VulpineLogic addons to serve web pages, primarily for OAUTH callbacks and OBS browser sources.

## Non-goals

For technical or simplicity reasons, this add-on has no plans to:

- Provide a robust, all-purpose HTTP server.

