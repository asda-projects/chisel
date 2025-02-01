# Changelog

All notable changes to this project will be documented in this file.

## [unreleased]

### <!-- 0 -->⛰️  Features

-  [2025-02-01 11:13]  Added test for web env ([9e38f19](9e38f19e626bbb1acffe9b44abd9ae6e99128b31))
-  [2025-02-01 06:34]  **storage**:  Replace 'dart:io' for cross-platform compatibility ([ecd2a58](ecd2a5879354448690306d30b1cbd95b2614f04f))

### <!-- 1 -->🐛 Bug Fixes

-  [2025-02-01 06:59]  Fixed non pushed correct chisel changes at ecd2a58 ([60145cb](60145cba71527e554348bcbe315c0b629462bdd3))

### <!-- 7 -->⚙️ Miscellaneous Tasks

-  [2025-02-01 04:54]  Fixed merge in development that came from main ([ac124c7](ac124c7953d9b384351e701d5978acc5650e0e41))

## [1.2.2] - 2025-01-30

[f70472a](f70472adc19fce776b2e2a451af3bf15403a1c6c)...[d910a96](d910a96f8923a818cd779e5b5f8a217bb6399ef9)

### <!-- 1 -->🐛 Bug Fixes

-  [2025-01-30 12:32]  Export ChiselConnectionSettings for public use ([2bec557](2bec5577ea5b3fa5390171800c8aa775f269ac74))

### <!-- 7 -->⚙️ Miscellaneous Tasks

-  [2025-01-30 12:40]  Fix logger formatting and remove unnecessary import ([d910a96](d910a96f8923a818cd779e5b5f8a217bb6399ef9))

## [1.2.1] - 2025-01-30

[1617afa](1617afa2afd83c3c4de801bacd8279f6dfbf69af)...[f70472a](f70472adc19fce776b2e2a451af3bf15403a1c6c)

### <!-- 0 -->⛰️  Features

-  [2025-01-30 10:23]  Re-export PostgreSQL types for simplified user imports ([64ca626](64ca6265902458a3e82233ca7ff39ce205e8d7b4))
-  [2025-01-30 09:40]  Improve PostgreSQL dependency settings ([c13e9f4](c13e9f4bc6fe7c488895fc9f69cc39e8e784cacc))
-  [2025-01-29 12:45]  **generateModels**:  Add forceUpdate to control regeneration behavior ([a9e0fc3](a9e0fc3e8557f3c347b6df60878771b1239d275c))
-  [2025-01-29 12:45]  **generateModels**:  Add forceUpdate to control regeneration behavior ([090bcc8](090bcc8e30bdf7dc2323149b5046f3061218ab81))

### <!-- 7 -->⚙️ Miscellaneous Tasks

-  [2025-01-30 12:02]  Prepared for  v1.2.1 ([f70472a](f70472adc19fce776b2e2a451af3bf15403a1c6c))
-  [2025-01-30 11:49]  Improve logging, optimize schema caching, and refine model operations ([d6f6172](d6f6172adf2cbfdc574726b6072b213bd5eb1c55))
-  [2025-01-30 09:59]  Merge feature branch into development ([f1a58f3](f1a58f39237a2ceedc7050401af12ac6f3a8f31c))
-  [2025-01-30 09:59]  Merge feature branch into development ([de2c531](de2c531aa2e17f24835553beb301d2aa7a3e0500))
-  [2025-01-29 13:17]  Merge release 1.1.0 into main ([a811613](a811613ea552940fb73b82d6f588b8f4f493e38b))
-  [2025-01-29 13:12]  Update files for release 1.1.0 ([c962829](c9628293ff3990c26def524db88f776b816ae80a))
-  [2025-01-29 07:15]  Added TODO.md in .gitignore ([6acba56](6acba56744fc2c01103a0a3d4eb74b1d6c50498a))

## [1.0.0] - 2025-01-29

[6603a51](6603a511607a161caf7ae9564a24aabbdea0d70a)...[1617afa](1617afa2afd83c3c4de801bacd8279f6dfbf69af)

### <!-- 0 -->⛰️  Features

-  [2025-01-28 11:54]  Implement robust CRUD operations, logging, and testing framework ([2f4ffa2](2f4ffa2a7c2f033e59a087072b5d1c265cfadf00))
-  [2025-01-28 08:59]  Improve Chisel database integration tests ([64f3b51](64f3b51da4c3a06b5eafd8875e04d3413d3ab0d6))
-  [2025-01-28 08:55]  Added a line breaker to be more understandable the log msgs ([f54796a](f54796a566b14305a5a8bab1c65f668b312d0a7b))
-  [2025-01-28 08:54]  Added a check if hasColums at Table to validate fields ([f82dbcf](f82dbcff103b3d631b409cc9329f9f18a2f7e917))
-  [2025-01-28 08:52]  Created a initialize function to simplify the process of mirroring ([c8ef65f](c8ef65fed0ac1e522a70c3fb90f391a48923b38f))
-  [2025-01-28 06:01]  Created a logger for the whole lib ([2411141](2411141cba289b9285538316ac39d3fb9d124b03))
-  [2025-01-27 09:33]  Modified  Column class to define a const constructor and created a ForeignKey class ([6c6b007](6c6b007b212fecfead2a593d4f5ef5df02500bc4))
-  [2025-01-27 09:19]  Add foreign key handling, model templates, and CRUD interface ([9f6816e](9f6816e559a9a86082cc48684bb0c1297b3731e9))
-  [2025-01-27 08:12]  Created a full step of mirroring the tables and column/fields type and test it ([ec44e4a](ec44e4aa53d54266fbbcc0aa9295517c9af21fb1))
-  [2025-01-27 07:14]  Created first interface for testing connection ([fc7d7cb](fc7d7cb3521d19dbad6a34844857e9605d475bbb))
-  [2025-01-27 06:56]  Added a separed module for querying string of tables and columns/fields ([12d8244](12d824430cfeb2dd41606d2afedb06ea53267e84))
-  [2025-01-27 06:51]  Improved some function to be acessible ([5332d83](5332d83775f308026395f5b1b8b74e8c5b04bc45))
-  [2025-01-27 05:25]  Implement SQL connection class ([a0a9aa5](a0a9aa5b0a0ac4bcd893146e4dac60ed689b443b))

### <!-- 7 -->⚙️ Miscellaneous Tasks

-  [2025-01-29 05:14]  **release**:  Finalize adjustments for v1.0.0 ([28e1f07](28e1f079a8781ca9fb3dab9c717de5e2c221b10f))
-  [2025-01-29 05:14]  **release**:  Finalize adjustments for v1.0.0 ([76eff1b](76eff1b5aaa08f1fd748a2c07daede95fa6af174))
-  [2025-01-27 06:54]  Added postgres and logging lib on pubspec ([296b6af](296b6afd39b99a191b1aa9eaf2bef0953e60232c))

### Release

-  [2025-01-29 05:28]  V1.0.0 - Initial release of Chisel ([1617afa](1617afa2afd83c3c4de801bacd8279f6dfbf69af))

## [0.1.0] - 2025-01-27

### <!-- 0 -->⛰️  Features

-  [2025-01-27 03:24]  Initial setup of Chisel library ([2c0861a](2c0861a48ee0395cfad6936148141de0a9de4f5f))

### <!-- 7 -->⚙️ Miscellaneous Tasks

-  [2025-01-27 04:21]  Bump version to 0.1.0 for release ([6603a51](6603a511607a161caf7ae9564a24aabbdea0d70a))
-  [2025-01-27 03:35]  Added a cliff.toml to organize CHANGELOG.md ([a8d7c19](a8d7c19ff0bcf489ef4367e7c4ae37287ac09b4a))

<!-- generated by git-cliff -->
