# Developer Guideline

An iOS application that makes note-taking process easier when learning languages.

## Features

- Create
- Save
- Upload/Sync

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

## Project Organization

The project organizes files and classes in a folder by their category and scene.

For example, in a vocabulary collection scene folder will consist of all specific classes used to create the scene.

On the other hand, for other classes that are not specific to a particular scene and are reusable elsewhere will be in their respective folders such as *Model*, *View*, or *Controller* folder.

### Project File Structure

The following structure illustrates how the folders are organized where the bolded lists are folders and the inner lists are files.

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
  - VocabularyCollectionTests.swift
  - VocabularyTests.swift
  - VocabularyConnectionTests.swift
  - TagTests.swift

## FAQ

### How do I contribute?

The repository is private at the moment.

## Support

- [Bug Reporting][emailto]
- [Contact Us][emailto]

[coredatalink]: https://developer.apple.com/documentation/coredata
[cloudkitlink]: https://developer.apple.com/documentation/cloudkit
[emailto]: mailto:bdaradev@gmail.com