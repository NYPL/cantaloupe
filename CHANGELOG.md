# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.6] - 2022-09-28

### Changed
- Changed response for filepath to serve no default image when an image is not found. (DR-2041)

## [0.1.5] - 2022-07-06

### Changed
- Changed logger calls to use already created logger. (DR-1925)
- Changed call to API to not be curl command but instead use basic net http. (DR-1925)
- Switch Repo API connections to https (DR-1958)

## [0.1.4] - 2022-05-13

### Added
- Added rights restrictions for regions of an image. (DR-1849)
- Added designated properties files for dev and prod. (DR-1865)

### Updaed
- Remove restrictions from info.json endpoint. (DR-1469)

## [0.1.3] - 2022-04-27

### Fixed
- Fixed info.json endpoint by using full_res rights logic. (DR-1838)

## [0.1.2] - 2022-04-01

### Updated
- Increased cache time by a factor of 2. (DR-1804)

## Fixed
- Fixed bug with cutting f derivatives. (DR-1764)

## [0.1.1] - 2022-03-24

### Updated
- Update properties to return cached content immediately, if available. (DR-1741)

### Added
- Added new type handling for tif requests. (DR-1678)

## [0.1.0] - 2022-02-04

### Updated
- Updated pecking order of derivatives to exclude u files. (DR-1611) 
- Updated pecking order of derivatives to include g, v, and q files. (DR-1611) 

### Added
- Changelog and new git flow branches. (DR-1360)
- Config files for qa and production. (DR-1360)
- Added rights aware logic to return appropriate capture types for an IP address. (DR-1529)
- Added 403 response for restricted images. (DR-1387)
