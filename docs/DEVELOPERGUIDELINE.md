---
layout: default
title: Developer Guideline
description: " "
---

# Developer Guideline

Welcome to FNote Project. The goal of the project is to build an iOS application that makes note-taking process easier when learning new languages.

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

## Project Organization

The project organizes files and classes in folders separated by their categories and scenes.

For example, the Vocabulary Collection Scene folder will consist of all classes used to create the scene.

On the other hand, for other classes that are not specific to a particular scene and are reusable elsewhere will be in their respective folders such as *Model*, *View*, or *Controller* folder.

### Project File Structure

The hierarchical structure below illustrates how the folders are organized. The bolded lists are folders and the inner lists are files.

- **Vocabulary Collection Scene**
  - VocabularyCollectionViewController.swift
  - VocabularyCollectionViewFlowLayout.swift
  - VocabularyCollectionCell.swift
- **Managed Object Model**
  - VocabularyCollection.swift
  - Vocabulary.swift
  - VocabularyConnection.swift
  - Tag.swift
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
  - UserProfileViewable.swift
  - NavigationItemToggleable.swift
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
  - Label.swift
- **Resource**
  - **User Guide**
    - add-collection-guide.json
    - add-vocabulary-guide.json
- **UnitTest**
  - VocabularyTests.swift
  - VocabularyConnectionTests.swift

## FAQ

### How do I contribute?

Contribution is not available at the moment.

## Support

- [Bug Reporting][emailto]
- [Contact Us][emailto]

[coredatalink]: https://developer.apple.com/documentation/coredata
[cloudkitlink]: https://developer.apple.com/documentation/cloudkit
[emailto]: mailto:bdaradev@gmail.com