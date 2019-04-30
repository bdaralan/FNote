---
layout:       default
title:        Developer  Guideline
description:  " "
---

# Developer Guideline <!-- omit in toc -->

Welcome to FNote Project. The goal of the project is to build an iOS application that makes note-taking process easier when learning new languages.

- [Core Features](#core-features)
- [Component Libraries](#component-libraries)
- [Requirements](#requirements)
- [Installation](#installation)
- [Project Convention](#project-convention)
  - [File Structure](#file-structure)
  - [Code Documentation](#code-documentation)
  - [Git Commit Message](#git-commit-message)
  - [Handle Enum Case](#handle-enum-case)
- [FAQ](#faq)
  - [How do I contribute?](#how-do-i-contribute)
  - [Is there a beta testing?](#is-there-a-beta-testing)
- [Support](#support)

## Core Features

- Create/Update/Delete vocabulary collection, vocabulary, and tags.
- Save data locally.
- Upload data to the cloud.
- Sync data across devices.

## Component Libraries

- [CoreData][coredatalink] - A framework that provides object graph management and persistence.
- [CloudKit][cloudkitlink] - A framework that provides interfaces for moving data between user's devices and user's iCloud.

## Requirements

- iOS 10.0+ / macOS 10.12+
- Xcode 10.2
- Swift 5.0+

## Installation

1. Download Xcode 10.2 from Mac App Store or Apple's developer website.
2. Clone the repository from [GitHub](https://github.com/iDara09/FNote)
   - Open up Terminal
   - `git clone https://github.com/iDara09/FNote.git`
3. Navigate to the project directory and open `FNote.xcodeproj` to start developing.

## Project Convention

The project organizes files and classes in folders separated by their categories and scenes.

For example, the Vocabulary Collection Scene folder will consist of all classes used to create the scene.

On the other hand, for other classes that are not specific to a particular scene and are reusable elsewhere will be in their respective folders such as *Model*, *View*, or *Controller* folder.

### File Structure

The hierarchical structure below illustrates how the folders are organized. The bolded lists are folders and the inner lists are files.

- **Vocabulary Collection Scene**
  - VocabularyCollectionViewController.swift
  - VocabularyCollectionCell.swift
- **Managed Object Model**
  - VocabularyCollection.swift
  - Vocabulary.swift
- **Model**
  - LocalRecord.swift
  - UserGuide.swift
- **View**
  - DescriptionGuideView.swift
  - TextFieldCell.swift
- **Controller**
  - MainTabBarViewController.swift
  - OptionTableViewController.swift
- **Protocol**
  - VocabularyViewable.swift
  - TextDisplayable.swift
- **Coordinator**
  - Coordinator.swift
  - VocabularyCollectionCoordinator.swift
- **Manager+Service**
  - CoreDataStack.swift
  - CloudKitService.swift
- **Extension+Utility**
  - Animation.swift
  - Image+Color.swift
- **Resource**
  - **User Guide**
    - add-collection-guide.json
    - add-vocabulary-guide.json
- **UnitTest**
  - VocabularyTests.swift
  - VocabularyConnectionTests.swift

### Code Documentation

Above `class`, `struct`, `enum`, method, property, or computed property, use the following format. Skip any of them as needed; for example, not every method has `/// - Complexity: [O(n)]`.

``` Swift
/// [Summary description]
///
/// [Discussion]
/// - Parameters:
///   - parameter1: [Description here]
///   - parameter2 [Description here]
/// - Note: [Note here]
/// - Warning: [Warning here]
/// - Complexity: [O(n)]
/// - Returns: [Return explanation here]
```

If needed to add self comments that are not part of the documentation, use `/**/` above the documentation.

- Single line

``` Swift
/* Self comment or note here */
/// [Summary Description]
///
/// [Discussion]
/// ...
```

- Two or more lines

``` Swift
/*
 Self comment or note here.
 If it is long or needed to use multiline.
 */
/// [Summary Description]
///
/// [Discussion]
/// ...
```

### Git Commit Message

There are two preferred commit styles, short and long commit message.

- Sort commit message

``` code
Implement reload cells when segment control changes
```

- Long commit message

``` code
Adjust controllers to better handle add and remove Tag
- OptionTableViewController
  - add method to set cancel and done button visibility
  - change delete option completion parameter
- VocabularyCollectionCoordinator
  - fix set tags method (better handle delete and add)
- VocabularyViewController
  - add methods to add and remove tag
```

### Handle Enum Case

When using `switch` with `enum`, avoid using `default`. List out all cases is preferred so that we can catch potential bugs at compile time.

## FAQ

### How do I contribute?

Make a pull request. :]

1. Clone the `master` branch to your local machine.
2. Checkout a new branch to work on.
3. After finishing with the branch you are working on, `commit` the changes.
4. Switch to back `master` branch and do a `git pull` to get changes if any.
5. Switch back to your working branch and merge any changes from `master`.
6. Push your branch to GitHub (if there is no conflict).
7. On GitHub website select your branch and click the green pull-request button.

### Is there a beta testing?

Please checkout public beta testing with TestFlight. [Public Beta Link][testflightlink].

## Support

- [Bug Reporting][emailto]
- [Contact Us][emailto]

[coredatalink]: https://developer.apple.com/documentation/coredata
[cloudkitlink]: https://developer.apple.com/documentation/cloudkit
[testflightlink]: https://testflight.apple.com/join/2kZ9H8L1
[emailto]: mailto:bdaradev@gmail.com