This repository contains the full source code for my submission for Paper 1, the first major paper assignment in the 2022 edition of INF 312.

## File Structure
- `data/`: Raw data files, downloaded from the Open Data Toronto portal as a CSV, are saved here. From there, the data-preparation script can read it as a cached version. To invalidate the file and re-download a fresh copy, change its name from `raw_data.csv` or delete it.
- `res/`: Static resources. In this case, this consists of a single directory, `img/`, containing a single additional image. These are included in the final paper automatically by `knitr`.
- `output/`: Files pertaining to the final, output paper. This includes:
  - `03-paper.rmd`, the RMarkdown file from which the text and plots of the PDF are drawn;
  - `03-paper.pdf`, the paper itself, once it is generated; and
  - `references.bib`, a bibTeX file containing all references of works cited. `knitr` includes and formats these automatically in the **References** section.
 
In the root directory, `01-setup.R` is an R script that handles the majority of data management, including fetching (or persisting) data from Open Data Toronto, reformatting values into a useful format, and performing summary statistics. `output/03-paper.rmd` automatically `source()`s this file in order to bring the data into local context.

If you use RStudio, the dotfiles -- `.RProj`, `Rhistory`, `.RData`, etc. -- will be of use to you and will help you to more easily explore the data, make modifications, and generally improve quality-of-life.


This repository, given that it is a single-purpose repository for a course assignment, is licensed by the Do What the Fuck You Want To Public License (WTFPL). I chose this license because I literally do not have a say what you do with this material, so to try to enforce anything less permissive would be difficult or impossible.
  