# rand-wiki-page
Opens a random Wikipedia page from your terminal.

## Usage
```
$ rand-wiki-page [-n] [-a] [-c CAT]
```
where
- `--no-conf` | `-n` opens a page without asking for confirmation;
- `--only-articles` | `-a` includes only articles (i.e., excludes categories and other non-article pages);
- `--cat` | `-c` specifies the category of the random page.

### Examples
To open, without confirmation, a random article in the 'Computer science' category:
```
$ rand-wiki-page -nacComputer_science
```
---
To open, asking for confirmation, a random article:
```
$ rand-wiki-page -a
```
