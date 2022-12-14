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
To open an article in the 'Computer Science' category without asking for confirmation:
```
$ rand-wiki-page -nacComputer_science
```
---
To open a random article asking for confirmation:
```
$ rand-wiki-page -a
```
