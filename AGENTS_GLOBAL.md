# Repository Guidelines

This project is about <short summary>
Always open when the question is directed at this project.

## Documentation

Documentation-specific instructions here

## Project Structure & Organization

Generic project structure
devenv, direnv, justfile

## Coding Standard

Global coding standards

### Language-specific

See the Python subsection below for example

### Language & coding tools

See the Language & coding tools below for example

### Python

- Format: 4-space indentation, 88-char lines, double quotes, and strict type hints (`basedpyright`). Modules use `snake_case`, classes `PascalCase`, functions and variables `snake_case`.

#### Python 3.13+ Typing Rules

- **Use the `type` statement for type aliases (PEP 695):** Instead of `typing.TypeAlias`, use the new `type` statement for creating aliases for types.
- Most imports from Typing are not required for annotation, except `Any`
- If unsure, fetch PEP695 (<https://peps.python.org/pep-0695/>)

  ```python
  # Preferred in Python 3.13+
  type Point = tuple[float, float]

  # Older syntax
  from typing import TypeAlias
  Point: TypeAlias = tuple[float, float]
  ```

- **Use generic type aliases (PEP 702):** Create generic aliases for types with type variables.

  ```python
  type ListOrTuple[T] = list[T] | tuple[T, ...]
  ```

- **Use builtin generics:** Prefer `list[int]` and `dict[str, float]` over `typing.List` and `typing.Dict`.
- **Use `|` for unions:** Use `int | None` instead of `typing.Optional[int]`.
- **Use modern typing features:**
  - `typing.Self`: For methods that return an instance of the class.
  - `typing.Literal`: For specifying a fixed set of possible values.
  - `typing.Final`: To indicate that a variable or attribute should not be reassigned.
  - `@typing.override`: To clearly mark methods that override a method from a superclass.
- **Use `if TYPE_CHECKING:` for heavy typing imports:** To avoid circular dependencies and improve runtime performance, place heavy typing imports inside an `if TYPE_CHECKING:` block.
- **Separate behavior and type information:** Docstrings should describe the *behavior* of a function or method, while type annotations should handle the type information.

### Language & coding tools

- LSP: basedpyright, ruff
- Lint: ruff
- Pre-commit hook to ensure

## Testing Guidelines

Global testing guidelines

## Commit & Pull Request Guidelines

- Follow the existing short-title style: `Feature or component: concise summary` (for example, `Justfile: tighten deploy tags`) with subjects ≤72 characters and contextual bodies.
- Be as specific as possible in the commit message. If possible, tie to a single component/class/function, otherwise use feature.
- One git branch per feature. Branch should be in the format `agent/feature` (component or feature)

## Security & Configuration Tips

- Do not commit secrets
- Keep `.env.*` files local
