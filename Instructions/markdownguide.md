[Documentation Home](../README.md)

# Markdown Guide

1. [Basic Syntax](#basic-syntax)
1. [Documentation File Structure](#documentation-file-structure)
   1. [Linking Between Files](#linking-between-files)

## Basic Syntax

Below is an example of Markdown Syntax. You can write almost any document with these commands.

```markdown
# This is a header
## This is a sub-header
### This is a sub-sub-header

1. This
1. Is a
1. Numbered List

* These
* Are
* Bullets
  * Indent by 2 spaces for sub-items

- Dashes
- Work
- Too

Three or more dashes creates a horizontal break

---
---

Embedding links is also very easy

Link to another document: [Documentation Home](../README.md)

Link to an external source: [Wikipedia](https://wikipedia.org)

Embed an image: ![Screenshot](../Images/clientdashboard.png)

```
---
The results of the above code is shown below:
# This is a header
## This is a sub-header
### This is a sub-sub-header

1. This
1. Is a
1. Numbered List

* These
* Are
* Bullets
  * Indent by 2 spaces for sub-items

- Dashes
- Work
- Too

Three or more dashes creates a horizontal break

---
---

Embedding links is also very easy

Link to another document: [Documentation Home](../README.md)

Link to an external source: [Wikipedia](https://wikipedia.org)

Embed an image: ![Screenshot](../Images/clientdashboard.png)

---

## Documentation File Structure

This documentation is comprised of dozens of individual Markdown files and images. It is important to know how each of these files fit together if you plan on contributing. 

### Basic Structure

The project starts with the [README](../README.md). This file lives in the ```Root``` of the file directory, along with a few folders that contain additional files. Below is a general map of the project file structure. Not every file is enumerated, but there are a few examples in every folder. 

```plain
|--README.md
|--\|Objects
|   |--[Documents about major CaseWorthy database objects]
|   |--Assessment.md
|   |--Client.md
|--\|Instructions
|   |--[User Intruction Manuals]
|   |--HousingDataEntryInstructions.md
|   |--Contribute.md
|   |--markdownguide.md (this document)
|--\|Images
|   |--[Screenshots]
|   |--clientdashboard.png
|--\|Forms
|   |--[Documents on individual CaseWorthy forms]
|   |--1000000004.md
|   |--1000000145.md
```

### Linking Between Files

When creating links in your documents it is important to understand the ***path*** between the two files. This file is in the Instructions folder, so it can link directly to other files that are also in the Instructions folder:

```markdown
[Contribute](Contribute.md)
```

#### Relative Paths

Files in other folders can be linked using a relative path.

```markdown
[Client Dashboard](../Images/clientdashboard.png)
```

- ```../``` Goes up one level in the file directory. In this case it brings you to the ```Root``` directory.
- ```Images/``` Goes into the ```Images``` folder, contained in the "Root" directory
- ```clientdashboard.png``` Goes to the specific file named ```clientdemographics.png``` in the ```Images``` folder.

```markdown
[Documentation Home](../README.md)
```

- ```../``` Goes up one level to the ```Root``` directory.
- ```README.md``` Goes to the specific file.

```../``` Can be used multiple times. ```../../``` will go up two levels instead of one. Consider this example file structure

```plain
|--README.md
|--\|Objects
|   |--[Documents about major CaseWorthy database objects]
|   |--Assessment.md (Link Destination)
|   |--Client.md
|--\|Instructions
|   |--[User Intruction Manuals]
|   |--HousingDataEntryInstructions.md
|   |--Contribute.md
|   |--markdownguide.md (this document)
|   |--\|Instructions Sub-Folder
|   |   |--Example.md (Link Origin)
|   |   |--AnotherExample.md
|   |   |--AThirdExample.md
```

A link between ```Example.md``` and ```Assessment.md``` would look like:

```markdown
[Assessment Home Page](../../Objects/Assessment.md)
```

- ```../../``` Takes you to the ```Root``` directory
- ```Objects/``` takes you into the ```Objects``` file folder
- ```Assessment.md``` links to the specific file.


