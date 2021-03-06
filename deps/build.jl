using BinaryProvider
using CxxWrap # this is needed for opening the dependency lib. Otherwise Libdl.dlopen fails

##################### LCIO ###########################
# We are trying to find the right version of LCIO. By default, don't set anything and the right version will just be downloaded. However, for debugging purposes, we'd might want to use the pre-installed lib
const lcioversion = "02-12-01"
const LCIO_DIR = get(ENV, "LCIO_DIR", "")
const verbose = "--verbose" in ARGS
const lcioprefix = Prefix(LCIO_DIR == "" ? get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")) : LCIO_DIR)

# The products that we will ensure are always built
lcioproducts = [
    LibraryProduct(lcioprefix, "liblcio", :liblcio),
    LibraryProduct(lcioprefix, "libsio", :libsio)
]
# Download binaries from hosted location
bin_prefix = "https://github.com/jstrube/LCIOBuilder/releases/download/v2.12.1-4"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    MacOS(:x86_64, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/LCIOBuilder.v2.12.1-4.x86_64-apple-darwin14-gcc7.tar.gz", "61be2eb8f7cd6345849781b65974cce76f8427a1f2b7e989480171604ca1dd70"),
    MacOS(:x86_64, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/LCIOBuilder.v2.12.1-4.x86_64-apple-darwin14-gcc8.tar.gz", "25bddf754aae66bcc09b549af7446abfd559fe6b5b994cca63faf463352818b1"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/LCIOBuilder.v2.12.1-4.x86_64-linux-gnu-gcc4.tar.gz", "1d541f3525ace53609df042599f715a01c7985ca8e0a97ccff108a02119b91f2"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/LCIOBuilder.v2.12.1-4.x86_64-linux-gnu-gcc7.tar.gz", "dd91bee706b76f9ea92a33366614ffc01250c233675e9a2df9280c7d72ed3f29"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc7, :cxx11)) => ("$bin_prefix/LCIOBuilder.v2.12.1-4.x86_64-linux-gnu-gcc7-cxx11.tar.gz", "c2c28c4456a74f14cc3d545b61ed88a9f41ac002716983ce2c4a24a84c36327f"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/LCIOBuilder.v2.12.1-4.x86_64-linux-gnu-gcc8.tar.gz", "4032161089689a3c87cd191c17d84f975d70960399c539546d9a4be3b6c1a747"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc8, :cxx11)) => ("$bin_prefix/LCIOBuilder.v2.12.1-4.x86_64-linux-gnu-gcc8-cxx11.tar.gz", "f4dde09b0975e4c4f280e4be08354356232e0b892f9d3ec56c22bbf6b645f986"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in lcioproducts)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=lcioprefix)
    # Download and install binaries
    install(dl_info...; prefix=lcioprefix, force=true, verbose=verbose)
end
######################################################

################### LCIO Wrapper #####################
const wrapprefix = Prefix(joinpath(@__DIR__, "usr"))

# Download binaries from hosted location
bin_prefix = "https://github.com/jstrube/LCIOWrapBuilder/releases/download/v0.6.2"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    MacOS(:x86_64, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/LCIOWrapBuilder-1.0.v0.6.2.x86_64-apple-darwin14-gcc7.tar.gz", "eed04efc9034367f14043efb15421661773b8731c81e5cc33c17a878232e1faf"),
    MacOS(:x86_64, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/LCIOWrapBuilder-1.0.v0.6.2.x86_64-apple-darwin14-gcc8.tar.gz", "7ce94541f3642fb014c24905ebcdccf96cfcbf6f87a4919399a14a270e18ea29"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc7, :cxx11)) => ("$bin_prefix/LCIOWrapBuilder-1.0.v0.6.2.x86_64-linux-gnu-gcc7-cxx11.tar.gz", "e5314b5332ed366c740f3056e2871db3a2820b11ed0b717569f4c92b98b11313"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc8, :cxx11)) => ("$bin_prefix/LCIOWrapBuilder-1.0.v0.6.2.x86_64-linux-gnu-gcc8-cxx11.tar.gz", "48b95738d405e7a6f3f3799f590206eb7873d81d838cee018007bc3aea80c069"),
)

# The products that we will ensure are always built
wrapproducts = [
    LibraryProduct(wrapprefix, "liblciowrap", :liblciowrap)
]

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in wrapproducts)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=wrapprefix)
    # Download and install binaries
    install(dl_info...; prefix=wrapprefix, force=true, verbose=verbose) 
end

write_deps_file(joinpath(@__DIR__, "deps.jl"), [lcioproducts; wrapproducts])
