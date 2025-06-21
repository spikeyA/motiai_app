Pod::Spec.new do |s|
  s.name             = 'leveldb-library'
  s.version          = '1.22.1'
  s.summary          = 'Fork of LevelDB for use by Firebase.'
  s.description      = <<-DESC
A fork of LevelDB, vendored for use by Firebase and other projects. This podspec is for local CocoaPods integration on macOS.
                   DESC
  s.homepage         = 'https://github.com/google/leveldb'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Google, Inc.' => 'firebase-ios-sdk@google.com' }
  s.platform         = :osx, '10.15'
  s.source           = { :git => 'https://github.com/google/leveldb.git', :tag => '1.22' }
  s.source_files     = '*.h', '*.cc', 'db/**/*.{h,cc}', 'helpers/**/*.{h,cc}', 'port/**/*.{h,cc}', 'table/**/*.{h,cc}', 'util/**/*.{h,cc}', 'include/**/*.{h,cc}'
  s.public_header_files = '*.h', 'include/leveldb/*.h', 'db/**/*.h', 'helpers/**/*.h', 'port/**/*.h', 'table/**/*.h', 'util/**/*.h'
  s.exclude_files    = 'db/c_test.c', 'db/c_test.cc', 'db/db_bench.cc', 'db/db_test.cc', 'db/dbformat_test.cc', 'db/filename_test.cc', 'db/log_test.cc', 'db/recovery_test.cc', 'db/skiplist_test.cc', 'db/version_edit_test.cc', 'db/version_set_test.cc', 'db/write_batch_test.cc', 'helpers/memenv/memenv_test.cc', 'table/table_test.cc', 'util/arena_test.cc', 'util/bloom_test.cc', 'util/cache_test.cc', 'util/coding_test.cc', 'util/crc32c_test.cc', 'util/env_test.cc', 'util/filter_policy_test.cc', 'util/hash_test.cc', 'util/logging_test.cc', 'util/testutil.cc', 'util/testutil.h'
  s.compiler_flags   = '-DOS_MACOSX'
  s.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '$(PODS_TARGET_SRCROOT) $(PODS_TARGET_SRCROOT)/include $(PODS_TARGET_SRCROOT)/include/leveldb $(PODS_TARGET_SRCROOT)/db $(PODS_TARGET_SRCROOT)/table',
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++11',
    'CLANG_CXX_LIBRARY' => 'libc++'
  }
  s.header_mappings_dir = '.'
end