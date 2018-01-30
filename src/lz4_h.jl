# Automatically generated using Clang.jl wrap_c, version 0.0.0

#using Compat

const OBJC_NEW_PROPERTIES = 1

# Skipping MacroDefinition: NULL ( ( void * ) 0 )
# Skipping MacroDefinition: offsetof ( t , d ) __builtin_offsetof ( t , d )
# Skipping MacroDefinition: LZ4FLIB_API __attribute__ ( ( __visibility__ ( "default" ) ) )
# Skipping MacroDefinition: LZ4F_DEPRECATE ( x ) x __attribute__ ( ( deprecated ) )

const LZ4F_VERSION = 100
const LZ4F_HEADER_SIZE_MAX = 19

# begin enum ANONYMOUS_28
const ANONYMOUS_28 = UInt32
const LZ4F_default = (UInt32)(0)
const LZ4F_max64KB = (UInt32)(4)
const LZ4F_max256KB = (UInt32)(5)
const LZ4F_max1MB = (UInt32)(6)
const LZ4F_max4MB = (UInt32)(7)
# end enum ANONYMOUS_28

# begin enum ANONYMOUS_29
const ANONYMOUS_29 = UInt32
const LZ4F_blockLinked = (UInt32)(0)
const LZ4F_blockIndependent = (UInt32)(1)
# end enum ANONYMOUS_29

# begin enum ANONYMOUS_30
const ANONYMOUS_30 = UInt32
const LZ4F_noContentChecksum = (UInt32)(0)
const LZ4F_contentChecksumEnabled = (UInt32)(1)
# end enum ANONYMOUS_30

# begin enum ANONYMOUS_31
const ANONYMOUS_31 = UInt32
const LZ4F_noBlockChecksum = (UInt32)(0)
const LZ4F_blockChecksumEnabled = (UInt32)(1)
# end enum ANONYMOUS_31

# begin enum ANONYMOUS_32
const ANONYMOUS_32 = UInt32
const LZ4F_frame = (UInt32)(0)
const LZ4F_skippableFrame = (UInt32)(1)
# end enum ANONYMOUS_32

# Skipping MacroDefinition: LZ4F_LIST_ERRORS ( ITEM ) ITEM ( OK_NoError ) ITEM ( ERROR_GENERIC ) ITEM ( ERROR_maxBlockSize_invalid ) ITEM ( ERROR_blockMode_invalid ) ITEM ( ERROR_contentChecksumFlag_invalid ) ITEM ( ERROR_compressionLevel_invalid ) ITEM ( ERROR_headerVersion_wrong ) ITEM ( ERROR_blockChecksum_invalid ) ITEM ( ERROR_reservedFlag_set ) ITEM ( ERROR_allocation_failed ) ITEM ( ERROR_srcSize_tooLarge ) ITEM ( ERROR_dstMaxSize_tooSmall ) ITEM ( ERROR_frameHeader_incomplete ) ITEM ( ERROR_frameType_unknown ) ITEM ( ERROR_frameSize_wrong ) ITEM ( ERROR_srcPtr_wrong ) ITEM ( ERROR_decompressionFailed ) ITEM ( ERROR_headerChecksum_invalid ) ITEM ( ERROR_contentChecksum_invalid ) ITEM ( ERROR_frameDecoding_alreadyStarted ) ITEM ( ERROR_maxCode )
# Skipping MacroDefinition: LZ4F_GENERATE_ENUM ( ENUM ) LZ4F_ ## ENUM ,

# begin enum ANONYMOUS_33
const ANONYMOUS_33 = UInt32
const LZ4F_OK_NoError = (UInt32)(0)
const LZ4F_ERROR_GENERIC = (UInt32)(1)
const LZ4F_ERROR_maxBlockSize_invalid = (UInt32)(2)
const LZ4F_ERROR_blockMode_invalid = (UInt32)(3)
const LZ4F_ERROR_contentChecksumFlag_invalid = (UInt32)(4)
const LZ4F_ERROR_compressionLevel_invalid = (UInt32)(5)
const LZ4F_ERROR_headerVersion_wrong = (UInt32)(6)
const LZ4F_ERROR_blockChecksum_invalid = (UInt32)(7)
const LZ4F_ERROR_reservedFlag_set = (UInt32)(8)
const LZ4F_ERROR_allocation_failed = (UInt32)(9)
const LZ4F_ERROR_srcSize_tooLarge = (UInt32)(10)
const LZ4F_ERROR_dstMaxSize_tooSmall = (UInt32)(11)
const LZ4F_ERROR_frameHeader_incomplete = (UInt32)(12)
const LZ4F_ERROR_frameType_unknown = (UInt32)(13)
const LZ4F_ERROR_frameSize_wrong = (UInt32)(14)
const LZ4F_ERROR_srcPtr_wrong = (UInt32)(15)
const LZ4F_ERROR_decompressionFailed = (UInt32)(16)
const LZ4F_ERROR_headerChecksum_invalid = (UInt32)(17)
const LZ4F_ERROR_contentChecksum_invalid = (UInt32)(18)
const LZ4F_ERROR_frameDecoding_alreadyStarted = (UInt32)(19)
const LZ4F_ERROR_maxCode = (UInt32)(20)
# end enum ANONYMOUS_33

# Skipping MacroDefinition: LZ4LIB_API __attribute__ ( ( __visibility__ ( "default" ) ) )

const LZ4_VERSION_MAJOR = 1
const LZ4_VERSION_MINOR = 8
const LZ4_VERSION_RELEASE = 0
const LZ4_VERSION_NUMBER = LZ4_VERSION_MAJOR * 100 * 100 + LZ4_VERSION_MINOR * 100 + LZ4_VERSION_RELEASE

# Skipping MacroDefinition: LZ4_LIB_VERSION LZ4_VERSION_MAJOR . LZ4_VERSION_MINOR . LZ4_VERSION_RELEASE
# Skipping MacroDefinition: LZ4_QUOTE ( str ) # str
# Skipping MacroDefinition: LZ4_EXPAND_AND_QUOTE ( str ) LZ4_QUOTE ( str )
# Skipping MacroDefinition: LZ4_VERSION_STRING LZ4_EXPAND_AND_QUOTE ( LZ4_LIB_VERSION )

const LZ4_MEMORY_USAGE = 14
const LZ4_MAX_INPUT_SIZE = 0x7e000000

# Skipping MacroDefinition: LZ4_COMPRESSBOUND ( isize ) ( ( unsigned ) ( isize ) > ( unsigned ) LZ4_MAX_INPUT_SIZE ? 0 : ( isize ) + ( ( isize ) / 255 ) + 16 )

const LZ4_HASHLOG = LZ4_MEMORY_USAGE - 2
const LZ4_HASHTABLESIZE = 1 << LZ4_MEMORY_USAGE
const LZ4_HASH_SIZE_U32 = 1 << LZ4_HASHLOG

# Skipping MacroDefinition: USER_ADDR_NULL ( ( user_addr_t ) 0 )
# Skipping MacroDefinition: CAST_USER_ADDR_T ( a_ptr ) ( ( user_addr_t ) ( ( uintptr_t ) ( a_ptr ) ) )

const INT8_MAX = 127
const INT16_MAX = 32767
const INT32_MAX = 2147483647
const INT64_MAX = Int64(9223372036854775807)
const INT8_MIN = -128
const INT16_MIN = -32768
const INT32_MIN = -INT32_MAX - 1
const INT64_MIN = -INT64_MAX - 1
const UINT8_MAX = 255
const UINT16_MAX = 65535
const UINT32_MAX = UInt32(4294967295)
const UINT64_MAX = UInt64(@int128_str("18446744073709551615"))
const INT_LEAST8_MIN = INT8_MIN
const INT_LEAST16_MIN = INT16_MIN
const INT_LEAST32_MIN = INT32_MIN
const INT_LEAST64_MIN = INT64_MIN
const INT_LEAST8_MAX = INT8_MAX
const INT_LEAST16_MAX = INT16_MAX
const INT_LEAST32_MAX = INT32_MAX
const INT_LEAST64_MAX = INT64_MAX
const UINT_LEAST8_MAX = UINT8_MAX
const UINT_LEAST16_MAX = UINT16_MAX
const UINT_LEAST32_MAX = UINT32_MAX
const UINT_LEAST64_MAX = UINT64_MAX
const INT_FAST8_MIN = INT8_MIN
const INT_FAST16_MIN = INT16_MIN
const INT_FAST32_MIN = INT32_MIN
const INT_FAST64_MIN = INT64_MIN
const INT_FAST8_MAX = INT8_MAX
const INT_FAST16_MAX = INT16_MAX
const INT_FAST32_MAX = INT32_MAX
const INT_FAST64_MAX = INT64_MAX
const UINT_FAST8_MAX = UINT8_MAX
const UINT_FAST16_MAX = UINT16_MAX
const UINT_FAST32_MAX = UINT32_MAX
const UINT_FAST64_MAX = UINT64_MAX
#const INTPTR_MAX = Int32(9223372036854775807)
#const INTPTR_MIN = -INTPTR_MAX - 1
#const UINTPTR_MAX = UInt32(@int128_str("18446744073709551615"))
const INTMAX_MIN = INT64_MIN
const INTMAX_MAX = INT64_MAX
const UINTMAX_MAX = UINT64_MAX
const PTRDIFF_MIN = INT64_MIN
const PTRDIFF_MAX = INT64_MAX
#const SIZE_MAX = UINTPTR_MAX
#const RSIZE_MAX = SIZE_MAX >> 1
#const WCHAR_MAX = __WCHAR_MAX__
#const WCHAR_MIN = -WCHAR_MAX - 1
const WINT_MIN = INT32_MIN
const WINT_MAX = INT32_MAX
const SIG_ATOMIC_MIN = INT32_MIN
const SIG_ATOMIC_MAX = INT32_MAX

# Skipping MacroDefinition: INT8_C ( v ) ( v )
# Skipping MacroDefinition: INT16_C ( v ) ( v )
# Skipping MacroDefinition: INT32_C ( v ) ( v )
# Skipping MacroDefinition: INT64_C ( v ) ( v ## LL )
# Skipping MacroDefinition: UINT8_C ( v ) ( v )
# Skipping MacroDefinition: UINT16_C ( v ) ( v )
# Skipping MacroDefinition: UINT32_C ( v ) ( v ## U )
# Skipping MacroDefinition: UINT64_C ( v ) ( v ## ULL )
# Skipping MacroDefinition: INTMAX_C ( v ) ( v ## L )
# Skipping MacroDefinition: UINTMAX_C ( v ) ( v ## UL )
# Skipping MacroDefinition: LZ4_STREAMSIZE_U64 ( ( 1 << ( LZ4_MEMORY_USAGE - 3 ) ) + 4 )
# Skipping MacroDefinition: LZ4_STREAMSIZE ( LZ4_STREAMSIZE_U64 * sizeof ( unsigned long long ) )

const LZ4_STREAMDECODESIZE_U64 = 4

# Skipping MacroDefinition: LZ4_STREAMDECODESIZE ( LZ4_STREAMDECODESIZE_U64 * sizeof ( unsigned long long ) )

#const LZ4_GCC_VERSION = __GNUC__ * 100 + __GNUC_MINOR__

# Skipping MacroDefinition: LZ4_DEPRECATED ( message ) __attribute__ ( ( deprecated ( message ) ) )

const LZ4HC_CLEVEL_MIN = 3
const LZ4HC_CLEVEL_DEFAULT = 9
const LZ4HC_CLEVEL_OPT_MIN = 11
const LZ4HC_CLEVEL_MAX = 12
const LZ4HC_DICTIONARY_LOGSIZE = 17
const LZ4HC_MAXD = 1 << LZ4HC_DICTIONARY_LOGSIZE
const LZ4HC_MAXD_MASK = LZ4HC_MAXD - 1
const LZ4HC_HASH_LOG = 15
const LZ4HC_HASHTABLESIZE = 1 << LZ4HC_HASH_LOG
const LZ4HC_HASH_MASK = LZ4HC_HASHTABLESIZE - 1
const LZ4_STREAMHCSIZE = 4LZ4HC_HASHTABLESIZE + 2LZ4HC_MAXD + 56
const LZ4_STREAMHCSIZE_SIZET = floor(Int, LZ4_STREAMHCSIZE / sizeof(Csize_t))
# Skipping MacroDefinition: LZ4_STREAMHCSIZE_SIZET ( LZ4_STREAMHCSIZE / sizeof ( size_t ) )




const LZ4_STREAMSIZE_U64 =((1 << (LZ4_MEMORY_USAGE-3)) + 4)
